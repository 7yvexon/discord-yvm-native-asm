class VendingMachineError(Exception):
    pass


class ValidationError(VendingMachineError):
    pass


class SettingsError(VendingMachineError):
    pass


class DatabaseError(VendingMachineError):
    pass
