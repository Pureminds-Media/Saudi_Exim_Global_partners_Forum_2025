<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Sponsor extends Model
{
    use HasFactory;

    public const TYPE_STRATEGIC_PARTNER = 'Strategic partner';
    public const TYPE_GOLD_PARTNER = 'Gold Partner';
    public const TYPE_DIAMOND_PARTNER = 'Diamond Partner';

    /**
     * @var array<int, string>
     */
    public const TYPES = [
        self::TYPE_STRATEGIC_PARTNER,
        self::TYPE_GOLD_PARTNER,
        self::TYPE_DIAMOND_PARTNER,
    ];

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name_en',
        'name_ar',
        'details_en',
        'details_ar',
        'type',
        'photo_path',
    ];
}
