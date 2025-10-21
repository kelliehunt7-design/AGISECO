package main

import (
    "fmt"
    "agiseco/modules/agismint"
    "agiseco/modules/agislearn"
    "agiseco/modules/agisearn"
    "agiseco/modules/agiswallet"
    "agiseco/modules/agisstats"
    "agiseco/modules/agiscompo"
    "agiseco/modules/agismine"
    "agiseco/modules/agismarket"
    "agiseco/modules/agischat"
    "agiseco/modules/agissettings"
    "agiseco/modules/security"
    "agiseco/modules/community"
    "agiseco/modules/experimental"
)

func main() {
    fmt.Println("🚀 AGISECO: Booting all modules...")
    agismint.Init()
    agislearn.Init()
    agisearn.Init()
    agiswallet.Init()
    agisstats.Init()
    agiscompo.Init()
    agismine.Init()
    agismarket.Init()
    agischat.Init()
    agissettings.Init()
    security.Init()
    community.Init()
    experimental.Init()
    fmt.Println("✅ All modules loaded successfully. Admin-only write access enforced.")
    fmt.Println("⚡ System ready for dev/admin use. Users can run all features but cannot modify core code.")
}
