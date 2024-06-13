---

# FiveM Car Boosting Script
## Features
- Car Boosting Missions: Players can receive vehicle orders and complete missions by delivering stolen cars to a drop-off point.
- Mission Tiers: Vehicles are categorized into three tiers with increasing difficulty and rewards.
  - Tier 3: Lowest tier, simple missions.
  - Tier 2: Medium difficulty, requires tracker removal.
  - Tier 1: Highest difficulty, multiple minigames for tracker removal.
- Minigames: Engaging minigames (Scrambler, Thermite, Maze) for removing trackers from vehicles.
- Police Dispatch Integration: Alerts the police when a player is boosting a car. The police receive updates if the vehicle tracker is active.
- Cooldown System: Prevents players from starting new missions immediately after completing one. During cooldown, players are advised to lay low.
- Interactive Ped: Players interact with a ped to start, cancel, or complete missions.
- Notifications and Emails: Players receive notifications and emails via qb-phone for mission details and cooldown warnings.
- Configurable Options: Easily adjust mission parameters, rewards, and cooldown times via the config file.

## Dependencies
- QBCore Framework: https://github.com/qbcore-framework/qb-core
- qb-target: https://github.com/qbcore-framework/qb-target
- ps-ui: https://github.com/Project-Sloth/ps-ui
- ps-dispatch: https://github.com/Project-Sloth/ps-dispatch

## Installation
1. Download the Script: Clone or download this repository.
2. Install Dependencies: Ensure all required dependencies are installed on your server.
3. Add to Server Resources: Place the script folder into your FiveM server's resources directory.
4. Update Server Configuration: Add the script to your server configuration file (server.cfg) with the following line:
   ensure qb-carboosting
5. Configuration: Adjust the config.lua file to suit your server's needs (e.g., mission parameters, rewards, cooldown times).

## Usage
- Starting a Mission: Interact with the specified ped to receive a vehicle order. Accept the order via the email on your phone.
- Completing a Mission: Steal the designated vehicle, remove any trackers if required, and deliver it to the drop-off point.
- Cooldown: After completing a mission, lay low for the specified cooldown period before starting another mission. If you interact with the ped during cooldown, you will alert the police.

## TO-DO
- Implement a reputation system that will define the tier of vehicles the player gets.
- Implement different drop-off locations for the cars -- Done
- Implement vinscratching as a process of the mission for tier 2 and above vehicles.
- Implement Ped spawning on the runs (owners) which will force the player to kill them or be fast enough to run -- Working on

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request for any enhancements or bug fixes.

## License
This project is licensed under the GPL-3.0 License. See the LICENSE file for details.
