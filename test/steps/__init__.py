import os
import pkgutil

# https://stackoverflow.com/questions/3365740/how-to-import-all-submodules/3365846#3365846
__all__ = []
PATH = [os.path.dirname(__file__)]
for loader, module_name, is_pkg in pkgutil.walk_packages(PATH):
    __all__.append(module_name)
    _module = loader.find_module(module_name).load_module(module_name)
    globals()[module_name] = _module
