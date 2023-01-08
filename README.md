# bgg_tools

## Quick Start

Scripting environment is only supported for Linux/OSX:

```
# Install any modern version of Ruby

# Install dependencies
bundle install

# Boot up REPL
bin/console

u = BggTools::User.new(user_id: 'hiimjosh')
u.ratings
```

## Directory Layout

There are two major types of applications in this repo:

* an Internet-deployed frontend (`dist/*`) which is accessible at: https://bgg-tools.onrender.com/
* an interactive scripting and data-analysis engine which is bootable via `bin/console`

```
.
├── bin
│   └── console           # REPL boot script
├── dist
│   └── index.html        # Landing page for web page
├── env.rb                # Responsible for loading/reloading all files for REPL environment
├── Gemfile               # Third-party dependencies
└── lib                   # Library functions
    ├── api.rb            # Everything related to making HTTP calls
    ├── ext.rb            # Extensions to core Ruby objects
    ├── geekauth.rb       # Wrapper which provides data access to session cookies
    ├── geeklist.rb
    ├── guild.rb
    ├── item.rb
    ├── play.rb
    ├── rating.rb
    ├── raw_init.rb       # Mixin for DRY'ing up code
    ├── search.rb
    ├── search_result_item.rb
    └── user.rb
```

## Contributing

Pull requests and issues are encouraged
