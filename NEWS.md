# roz 0.0.3

* Add `tools/exercise_roz_api.R` for testing the interface between `roz` and the OZ API.
* Remove return value from `oz_basereq()`.
* Force ott ids to be returned by `node_images()` as integers.
* Mitigate issue with header values from the OneZoom popularity endpoint. See [Issue #875](https://github.com/OneZoom/OZtree/issues/875) for details.

# roz 0.0.2

* Add `node_images()` to allow for retrieval of public domain and cc images.
* Add experimental `identifier2ott()` function to allow for mapping between other ids and ott.

# roz 0.0.1

* Add `popularity()` to allow for onezoom popularity score retrieval.
* Add converters for ott ids to other ids/names: `ott2*()`.
