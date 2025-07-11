# Triage Counter

Triage app for emergency medical and TEMS teams. Quickly log patient categories and monitor time from first patient arrival. Simple interface: add patients, start/stop timers, and reset counters.

## 🌟 Features

- Triage categorization of patients (plus, minus and reset)
- Time counter which can be started, stopped and resetted

## 📸 Screenshots

<img src="https://github.com/jisosavi/TriageCounter/blob/main/screenshots/Triage%20Counter_Screenshot_01.jpg" width="250">

## 🚀 Getting Started

### Prerequisites

If you use VS Code this it how it works:

- Install the Garmin Connect IQ SDK
- Install the "Monkey C" extension for VS Code
- Configure your VS Code settings.json to include the SDK path:

json:
Copy
{
    "connectiq.sdkPath": "path/to/your/connectiq-sdk"
}

- Create a new Connect IQ project using the folder structure above
- Build the project using the Connect IQ: Build command in VS Code
- Test in the simulator using Connect IQ: Run in Simulator

I could not create the IQ Store compatible .iq file with VS Code compiler. It only worked from the terminal.
Also, make sure you don´t have any warnings, the Store validator is very picky.

### Installation

Clone the repository and you should be ok!
