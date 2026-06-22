# ggsketch: Grammar-Native Hand-Drawn Geoms for 'ggplot2'

Provides 'ggplot2' geoms that render with a hand-drawn, sketchy
aesthetic: roughened strokes, double-pass lines, and hachure,
cross-hatch, zigzag, and dots fill patterns. Implemented as pure-R
'grid' grobs wrapped in 'ggproto' geoms, composable with aes(), stats,
scales, and faceting. Works on every R graphics device (PDF, PNG, SVG,
screen) with no browser dependency. Algorithms are reimplemented from
the published 'rough.js' algorithm description (Shihn, 2020,
<https://shihn.ca/posts/2020/roughjs-algorithms/>) and Wood and others
(2012,
[doi:10.1109/TVCG.2012.262](https://doi.org/10.1109/TVCG.2012.262) );
see the NOTICE file in the package sources for attribution.

## See also

Useful links:

- <https://github.com/orijitghosh/ggsketch>

- <https://orijitghosh.github.io/ggsketch/>

- Report bugs at <https://github.com/orijitghosh/ggsketch/issues>

## Author

**Maintainer**: Arijit Ghosh <arijitghosh2009@gmail.com>
