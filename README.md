Overview
--------

nearest adds the nearset method to the Ruby Time class. This allows you to get the nearest X minutes from a given time. The argument to the nearest method is in seconds to keep the Ruby code more readable.
e.g. time.nearest(15.minutes)

This is useful if you break up hours into regular intervals such as every 15 minutes. It also can optionally forcing the time period to be in the future or past instead of the closest (either future or past) from the given time.

Setup & Installation
--------------------

Install with `[sudo] gem install nearest`

Include it in your project's `Gemfile`:

``` ruby
gem 'nearest'
```

License
---------

This is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License Version 2 as published by the Free Software Foundation: www.gnu.org/copyleft/gpl.html

This is just a tiny gem for some very specific functionality I found myself needing in not only other apps but other gems as well.

As with all my work, please feel free to use it for whatever you like except in the assistance of robots or chimpanzees taking over the world. Nothing will ever get me to trust a chimpanzee.