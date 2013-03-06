Array.isArray ?= (arr) -> Object::toString.call(arr) is "[object Array]"

window.SourceScript = require './index'
