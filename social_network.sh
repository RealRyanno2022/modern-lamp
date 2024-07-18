#!/bin/bash

# Update and install necessary packages
sudo apt update
sudo apt install -y docker.io docker-compose git

# Create a directory for the project
mkdir social_network
cd social_network

F

# Create Laravel project
docker run --rm -v $(pwd)/src:/var/www/html -w /var/www/html laravelsail/php74-composer:latest composer create-project --prefer-dist laravel/laravel .

# Generate Laravel application key
docker run --rm -v $(pwd)/src:/var/www/html -w /var/www/html laravelsail/php74-composer:latest php artisan key:generate

# Create basic migration, model, and controller
cat <<EOF > src/database/migrations/2024_01_01_000000_create_entries_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateEntriesTable extends Migration
{
    public function up()
    {
        Schema::create('entries', function (Blueprint \$table) {
            \$table->id();
            \$table->string('title');
            \$table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('entries');
    }
}
EOF

# Create Entry model
cat <<EOF > src/app/Models/Entry.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Entry extends Model
{
    use HasFactory;

    protected \$fillable = ['title'];
}
EOF

# Create basic controller
cat <<EOF > src/app/Http/Controllers/EntryController.php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Entry;

class EntryController extends Controller
{
    public function index()
    {
        \$entry = Entry::first();
        return view('welcome', compact('entry'));
    }

    public function store()
    {
        Entry::create(['title' => 'My first database entry']);
        return redirect('/');
    }

    public function show()
    {
        \$entry = Entry::first();
        return response()->json(\$entry);
    }

    public function playVideo()
    {
        return view('play');
    }
}
EOF

# Update web routes
cat <<EOF > src/routes/web.php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\EntryController;

Route::get('/', [EntryController::class, 'index']);
Route::post('/add', [EntryController::class, 'store'])->name('add');
Route::get('/fetch', [EntryController::class, 'show'])->name('fetch');
Route::get('/play', [EntryController::class, 'playVideo'])->name('play');
EOF

# Update welcome view
cat <<EOF > src/resources/views/welcome.blade.php
<!DOCTYPE html>
<html>
<head>
    <title>Hello World</title>
    <script>
        function fetchEntry() {
            fetch('/fetch')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('database-entry').innerText = data.title;
                    document.getElementById('database-entry').style.display = 'block';
                });
        }
    </script>
</head>
<body>
    <h1>Hello world!</h1>
    <form action="{{ route('add') }}" method="POST">
        @csrf
        <button type="submit">Add to database!</button>
    </form>
    <button onclick="fetchEntry()">Call from database!</button>
    <p id="database-entry" style="display:none;"></p>
    <a href="{{ route('play') }}"><button>Bad times ahead!</button></a>
</body>
</html>
EOF

# Create play view
cat <<EOF > src/resources/views/play.blade.php
<!DOCTYPE html>
<html>
<head>
    <title>Megalovania</title>
    <style>
        body, html {
            height: 100%;
            margin: 0;
        }
        .fullscreen-video {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
        .center-button {
            position: absolute;
            top: 20px;
            left: 20px;
            z-index: 1;
        }
    </style>
</head>
<body>
    <div class="center-button">
        <a href="/"><button>Go back!</button></a>
    </div>
    <iframe class="fullscreen-video" src="https://www.youtube.com/embed/wDgQdr8ZkTw?autoplay=1" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
</body>
</html>
EOF

# Run migrations
docker-compose run --rm app php artisan migrate

# Bring up the Docker containers
docker-compose up -d

echo "Social Network setup is complete. Access your Laravel application at http://localhost:1916"

