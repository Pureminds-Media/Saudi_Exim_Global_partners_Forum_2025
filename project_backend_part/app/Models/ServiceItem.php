<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Support\Facades\Storage;

class ServiceItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'service_category_id',
        'name_ar',
        'name_en',
        'short_des_ar',
        'short_des_en',
        'des_ar',
        'des_en',
        'thumbnail_path',
        'photo_path',
        'website',
        'location_link',
        'sort_order',
    ];

    protected $appends = [
        'thumbnail_url',
        'photo_url',
    ];

    public function getThumbnailUrlAttribute(): ?string
    {
        return $this->thumbnail_path ? Storage::disk('public')->url($this->thumbnail_path) : null;
    }

    public function getPhotoUrlAttribute(): ?string
    {
        return $this->photo_path ? Storage::disk('public')->url($this->photo_path) : null;
    }

    protected static function booted(): void
    {
        static::deleting(function (ServiceItem $item) {
            if ($item->photo_path) {
                Storage::disk('public')->delete($item->photo_path);
            }
            if ($item->thumbnail_path) {
                Storage::disk('public')->delete($item->thumbnail_path);
            }
        });
    }

    /**
     * @return BelongsToMany<City>
     */
    public function cities(): BelongsToMany
    {
        return $this->belongsToMany(City::class);
    }

    /**
     * @return BelongsTo<ServiceCategory, ServiceItem>
     */
    public function serviceCategory(): BelongsTo
    {
        return $this->belongsTo(ServiceCategory::class, 'service_category_id');
    }
}
