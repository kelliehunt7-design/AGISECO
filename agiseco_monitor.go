package main

import (
	"log"
	"os"
	"os/exec"
	"time"
)

const (
	coreBinary = "/home/akay/AGISECO_REPO/agiseco" // path to AGISECO binary
	logFile    = "/home/akay/AGISECO_REPO/agiseco_monitor.log"
	restartDelay = 3 * time.Second // wait before restarting AGISECO
)

func main() {
	// Open log file
	f, err := os.OpenFile(logFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatalf("❌ Cannot open log file: %v", err)
	}
	defer f.Close()
	logger := log.New(f, "", log.LstdFlags)

	logger.Println("🚀 AGISECO Monitor started.")

	for {
		logger.Println("▶ Starting AGISECO Core...")
		cmd := exec.Command(coreBinary)
		cmd.Stdout = f
		cmd.Stderr = f

		err := cmd.Start()
		if err != nil {
			logger.Printf("❌ Failed to start AGISECO: %v\n", err)
			time.Sleep(restartDelay)
			continue
		}

		logger.Printf("✅ AGISECO running with PID %d\n", cmd.Process.Pid)

		// Wait for AGISECO to exit
		err = cmd.Wait()
		if err != nil {
			logger.Printf("⚠ AGISECO crashed: %v\n", err)
		} else {
			logger.Println("ℹ AGISECO exited normally.")
		}

		logger.Printf("⏳ Restarting AGISECO in %v...\n", restartDelay)
		time.Sleep(restartDelay)
	}
}

