<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Support\Facades\Storage;

class City extends Model
{
    use HasFactory;

    protected $fillable = [
        'name_ar',
        'name_en',
        'des_ar',
        'des_en',
        'photo_path',
        'sort_order',
    ];

    protected $appends = [
        'photo_url',
    ];

    public function getPhotoUrlAttribute(): ?string
    {
        return $this->photo_path ? Storage::disk('public')->url($this->photo_path) : null;
    }

    protected static function booted(): void
    {
        static::deleting(function (City $city) {
            if ($city->photo_path) {
                Storage::disk('public')->delete($city->photo_path);
            }
        });
    }

    /**
     * @return BelongsToMany<ServiceItem>
     */
    public function serviceItems(): BelongsToMany
    {
        return $this->belongsToMany(ServiceItem::class);
    }
}
