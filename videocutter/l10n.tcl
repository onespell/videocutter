package require msgcat

namespace import msgcat::mc

msgcat::mcload [file join [file dirname [info script]] l10n]
