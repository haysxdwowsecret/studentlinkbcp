<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Twilio Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration for Twilio SMS service integration
    |
    */

    'sid' => env('TWILIO_SID'),
    'token' => env('TWILIO_TOKEN'),
    'from' => env('TWILIO_FROM'),
    
    /*
    |--------------------------------------------------------------------------
    | SMS Settings
    |--------------------------------------------------------------------------
    */
    
    'sms' => [
        'enabled' => env('TWILIO_SMS_ENABLED', true),
        'from_number' => env('TWILIO_FROM'),
        'webhook_url' => env('TWILIO_WEBHOOK_URL'),
    ],
    
    /*
    |--------------------------------------------------------------------------
    | Rate Limiting
    |--------------------------------------------------------------------------
    */
    
    'rate_limit' => [
        'max_attempts' => env('TWILIO_RATE_LIMIT_MAX_ATTEMPTS', 5),
        'decay_minutes' => env('TWILIO_RATE_LIMIT_DECAY_MINUTES', 60),
    ],
];
