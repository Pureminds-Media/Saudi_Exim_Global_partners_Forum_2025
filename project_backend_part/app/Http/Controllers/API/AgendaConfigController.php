<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\AgendaConfig;

class AgendaConfigController extends Controller
{
    /**
     * GET /api/agenda-config/{slug}/keys
     * Returns flattened key => value pairs for agenda configuration.
     */
    public function index(string $slug = 'default')
    {
        $config = AgendaConfig::where('slug', $slug)->firstOrFail();

        return response()->json([
            'slug' => $config->slug,
            'data' => $this->flattenAgenda($config->data ?? []),
        ]);
    }

    /**
     * GET /api/agenda-config/{slug}/keys/{key}
     * Fetch a single value by flattened key.
     */
    public function showKey(string $slug, string $key)
    {
        $config = AgendaConfig::where('slug', $slug)->firstOrFail();
        [$found, $value] = $this->getByKey($config->data ?? [], $key);

        if (! $found) {
            abort(404, "Key not found: $key");
        }

        return response()->json([
            'slug' => $config->slug,
            'key'  => $key,
            'value'=> $value,
        ]);
    }

    /**
     * Flatten agenda JSON into dot-like keys.
     */
    private function flattenAgenda(array $data): array
    {
        $out = [];

        $days = $data['days'] ?? [];
        foreach ($days as $dayItem) {
            if (! isset($dayItem['day'])) {
                continue;
            }
            $dayNum = $dayItem['day'];
            $base = "days.day.$dayNum";

            if (array_key_exists('title_en', $dayItem)) {
                $out["$base.title_en"] = $dayItem['title_en'];
            }
            if (array_key_exists('title_ar', $dayItem)) {
                $out["$base.title_ar"] = $dayItem['title_ar'];
            }

            $fixed = $dayItem['fixed'] ?? [];
            foreach ($fixed as $i => $fix) {
                $fbase = "$base.fixed.$i";
                foreach (['start','end','title_en','title_ar','desc_en','desc_ar'] as $k) {
                    if (array_key_exists($k, $fix)) {
                        $out["$fbase.$k"] = $fix[$k];
                    }
                }
            }
        }

        return $out;
    }

    /**
     * Get a value by custom key scheme.
     */
    private function getByKey(array $data, string $key): array
    {
        if (! str_starts_with($key, 'days.day.')) {
            return [false, null];
        }

        $rest = substr($key, strlen('days.day.'));
        $parts = explode('.', $rest);
        if (count($parts) < 1) {
            return [false, null];
        }

        $dayNum = $parts[0];
        if (! ctype_digit((string) $dayNum)) {
            return [false, null];
        }
        $dayNum = (int) $dayNum;

        $days = $data['days'] ?? [];
        $dayIndex = null;
        foreach ($days as $idx => $day) {
            if (($day['day'] ?? null) === $dayNum) {
                $dayIndex = $idx;
                break;
            }
        }
        if ($dayIndex === null) {
            return [false, null];
        }

        if (count($parts) === 1) {
            return [true, $days[$dayIndex]];
        }

        $subpath = implode('.', array_slice($parts, 1));

        if (str_starts_with($subpath, 'fixed.')) {
            $subParts = explode('.', $subpath);
            if (count($subParts) < 3) {
                return [false, null];
            }
            $i = $subParts[1];
            if (! ctype_digit((string) $i)) {
                return [false, null];
            }
            $i = (int) $i;
            $field = implode('.', array_slice($subParts, 2));

            $value = $days[$dayIndex]['fixed'][$i][$field] ?? null;
            $exists = array_key_exists('fixed', $days[$dayIndex])
                   && array_key_exists($i, $days[$dayIndex]['fixed'])
                   && array_key_exists($field, $days[$dayIndex]['fixed'][$i]);

            return [$exists, $value];
        }

        $exists = array_key_exists($subpath, $days[$dayIndex]);
        $value  = $days[$dayIndex][$subpath] ?? null;

        return [$exists, $value];
    }
}
