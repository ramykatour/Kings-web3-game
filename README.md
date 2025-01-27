# Kings Web3 Game

![Kings Game](./kings.jpg)

## 🎮 Overview

**Kings Web3 Game** is a blockchain-based game that integrates staking, rewards, and battles into a fun and interactive gameplay experience. Players stake their **Coinzax tokens**, earn **Kings tokens**, level up, and participate in challenges and battles.

---

## 🛠 Features

- **Staking System**: Stake **Coinzax tokens** to earn **Kings tokens** and rewards.
- **Leveling Up**: Gain XP to level up and unlock better rewards.
- **Weapons System**: Purchase weapons to enhance your power in battles.
- **Battle Mode**: Compete with other players to earn rewards and improve your stats.
- **Tax Distribution**: Periodic tax rewards for eligible players.

---

## 🚀 How to Run the Project

Follow these steps to set up and run the project:

### 1. Clone the Repository
```bash
git clone https://github.com/ramykatour/Kings-web3-game.git
```

### 2. Navigate to the Project Directory
```bash
cd Kings-web3-game
```

### 3. Install Dependencies
```bash
npm install
```

### 4. Start the Development Server
```bash
npm run dev
```

---

## 📂 Project Structure

The project is organized as follows:

```
Kings-web3-game/
├── public/
│   └── kings.png
├── src/
│   ├── components/
│   │   ├── Staking.js
│   │   ├── Battle.js
│   │   └── Weapons.js
│   ├── styles/
│   │   └── styles.css
│   ├── app.js
│   └── config.js
├── index.html
├── README.md
└── package.json
```

---

## 📚 Frequently Asked Questions (FAQ)

### 1. **What is the main goal of the game?**
   The main goal of the game is to stake your Coinzax tokens, earn Kings tokens, level up, and compete with other players through challenges and battles.

### 2. **What tokens are used in the game?**
   - **Coinzax**: The primary token used for staking.
   - **Kings**: The reward token earned through staking and battles.

### 3. **How do I start playing the game?**
   You need to:
   1. Register as a player by interacting with the staking contract.
   2. Stake a minimum amount of Coinzax tokens (50 tokens) to activate your account and start earning rewards.

### 4. **What are the benefits of staking?**
   - Earn Kings tokens as rewards.
   - Gain XP to level up.
   - Unlock access to features like purchasing weapons and participating in challenges.

### 5. **How do levels work in the game?**
   Levels are based on the XP you earn. Once your XP exceeds the threshold for the next level, you automatically level up and gain additional benefits, such as increased rewards and higher status.

### 6. **What are weapons, and why do I need them?**
   Weapons enhance your power in battles. Without a weapon, you cannot challenge or accept challenges. Each weapon has a specific power and price in Kings tokens.

### 7. **How do I buy weapons?**
   You can purchase weapons using Kings tokens. Each weapon has a fixed price and provides a specific power boost.

### 8. **What happens during a challenge?**
   - Two players compete based on their weapon power and a random factor.
   - The winner earns 100 Kings tokens and gains 50 XP.
   - The battle statistics (wins and losses) are updated for both players.

### 9. **Can I decline a challenge?**
   Yes, you can decline a challenge, but you will incur a penalty of 10 Kings tokens, which will be deducted from your balance.

### 10. **What happens if I lose a battle?**
   - Your loss is recorded in your player statistics.
   - You do not lose your staked tokens or XP.

### 11. **How are taxes distributed in the game?**
   A tax is applied to players' stakes based on the current tax rate (e.g., 10%). Taxes are distributed periodically to eligible players as rewards.

### 12. **What is the minimum amount required to stake?**
   The minimum amount required to stake is **50 Coinzax tokens**.

### 13. **Can I unstake my tokens anytime?**
   You can unstake your tokens after the lock period of 30 days. Attempting to unstake before this period will result in an error.

### 14. **What happens if I don’t have enough Kings tokens for a transaction?**
   You won’t be able to complete the transaction, such as purchasing weapons or paying penalties. Ensure you have sufficient Kings tokens in your balance.

### 15. **How is randomness determined in battles?**
   A random factor is calculated using the current block timestamp and prevrandao, ensuring fairness in battles.

### 16. **Does the contract accept Ether?**
   No, the contract does not accept Ether. All transactions are done using Coinzax and Kings tokens.

### 17. **Can I register multiple accounts?**
   While technically possible, it is not recommended as it may dilute your overall performance and rewards.

### 18. **What happens if a challenge expires?**
   If a challenge is not accepted within 24 hours, it expires, and no penalties or rewards are applied.

### 19. **Who can update the game settings?**
   Only the contract owner has the authority to update settings such as the tax rate, lock period, or add new weapons.

### 20. **What should I do if I encounter an issue?**
   Please reach out to the support team via the contact section on the website for assistance.

---

## 📄 License

This project is licensed under the [MIT License](./LICENSE).

---

## 🤝 Contribution

Contributions are welcome! Please fork the repo, create a branch, and submit a pull request.

---

## 📞 Contact

For support or questions, feel free to reach out to [Ramy Katour](https://github.com/ramykatour).
