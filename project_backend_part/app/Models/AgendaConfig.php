<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class AgendaConfig extends Model
{
    protected $fillable = ['slug', 'data'];

    protected $casts = [
        'data' => 'array',
    ];
}
