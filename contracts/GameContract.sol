// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ReentrancyGuard.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function mint(address account, uint256 amount) external;
}

contract KingsGame is ReentrancyGuard {
    IERC20 public coinzax; 
    IERC20 public kings;
    address public owner;

    uint256 public lockPeriod = 30 days;
    uint256 public taxRate = 10;
    uint256 public minStake = 50;

    uint256[] public levelThresholds;

    address[] private players;
    mapping(address => bool) private isPlayer;

    mapping(address => uint256) public stakes;
    mapping(address => uint256) public stakeTime;
    mapping(address => uint256) public playerLevel;
    mapping(address => uint256) public playerXP;
    mapping(address => uint256) public playerTaxes;
    mapping(address => uint256) public totalRewards;

    struct Weapon {
        uint256 power;
        uint256 price;
    }
    mapping(uint256 => Weapon) public weapons;
    mapping(address => uint256[]) public playerWeapons;

    mapping(address => address) public playerChallenges;
    mapping(address => uint256) public challengeExpiry;
    mapping(address => uint256) public rejectedChallenges;

    struct PlayerStats {
        uint256 wins;
        uint256 losses;
        uint256 challengesIssued;
        uint256 challengesAccepted;
    }
    mapping(address => PlayerStats) public playerStats;
    mapping(address => uint256) public playerResources;

    event Staked(address indexed player, uint256 amount);
    event Unstaked(address indexed player, uint256 amount);
    event RewardPaid(address indexed player, uint256 reward);
    event WeaponPurchased(
        address indexed player,
        uint256 weaponId,
        uint256 price
    );
    event TaxDistributed(uint256 totalTaxAmount);
    event ChallengeCreated(
        address indexed challenger,
        address indexed opponent
    );
    event ChallengeAccepted(address indexed challenger,address indexed opponent,address winner,uint256 reward);
    event ChallengeDeclined(address indexed challenger,address indexed opponent,uint256 penalty);
    event LevelUp(address indexed player, uint256 newLevel);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyPlayer() {
        require(isPlayer[msg.sender], "You must be a registered player");
        _;
    }

    constructor(address _coinzax,address _kings,uint256[] memory _levelThresholds)
	{
        require(_coinzax != address(0) && _kings != address(0),"Invalid token address");
        coinzax = IERC20(_coinzax);
        kings = IERC20(_kings);
        owner = msg.sender;
        levelThresholds = _levelThresholds;

        weapons[1] = Weapon({power: 10, price: 100 * 10 ** 18}); // Sword
        weapons[2] = Weapon({power: 30, price: 300 * 10 ** 18}); // Laser Gun
        weapons[3] = Weapon({power: 50, price: 500 * 10 ** 18}); // Battle Axe
        weapons[4] = Weapon({power: 70, price: 700 * 10 ** 18}); // Plasma Blaster
        weapons[5] = Weapon({power: 15, price: 150 * 10 ** 18}); // Ninja Dagger
        weapons[6] = Weapon({power: 90, price: 900 * 10 ** 18}); // Energy Sword
        weapons[7] = Weapon({power: 120, price: 1200 * 10 ** 18}); // Dragon Claw
        weapons[8] = Weapon({power: 45, price: 450 * 10 ** 18}); // Crossbow
        weapons[9] = Weapon({power: 65, price: 650 * 10 ** 18}); // Thunder Hammer
        weapons[10] = Weapon({power: 80, price: 800 * 10 ** 18}); // Inferno Gun
        weapons[11] = Weapon({power: 100, price: 1000 * 10 ** 18}); // Ice Spear
        weapons[12] = Weapon({power: 40, price: 400 * 10 ** 18}); // Poisonous Dagger
        weapons[13] = Weapon({power: 110, price: 1100 * 10 ** 18}); // Mystic Staff
        weapons[14] = Weapon({power: 130, price: 1300 * 10 ** 18}); // Phantom Blade
        weapons[15] = Weapon({power: 150, price: 1500 * 10 ** 18}); // Light Sword
    }

    function registerPlayer() internal {
        if (!isPlayer[msg.sender]) {
            players.push(msg.sender);
            isPlayer[msg.sender] = true;
            playerLevel[msg.sender] = 1;
        }
    }

    function stake(uint256 amount) public nonReentrant {
        require(amount >= minStake, "Amount is below the minimum stake");
        registerPlayer();

        coinzax.transferFrom(msg.sender, address(this), amount);

        stakes[msg.sender] += amount;
        stakeTime[msg.sender] = block.timestamp;

        uint256 kingsToMint = amount / 10;
        kings.mint(msg.sender, kingsToMint);

        uint256 xpGained = amount / 10;
        addXP(msg.sender, xpGained);

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) public nonReentrant {
        require(stakes[msg.sender] >= amount, "Insufficient staked balance");
        require(
            block.timestamp >= stakeTime[msg.sender] + lockPeriod,
            "Cannot unstake before lock period"
        );

        stakes[msg.sender] -= amount;
        coinzax.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    function buyWeapon(uint256 weaponId) public nonReentrant {
        Weapon memory weapon = weapons[weaponId];
        require(weapon.price > 0, "Invalid weapon ID");
        require(
            kings.balanceOf(msg.sender) >= weapon.price,
            "Insufficient Kings balance"
        );

        kings.transferFrom(msg.sender, address(this), weapon.price);
        playerWeapons[msg.sender].push(weaponId);

        emit WeaponPurchased(msg.sender, weaponId, weapon.price);
    }

    function addXP(address player, uint256 amount) internal {
        playerXP[player] += amount;

        while (
            playerLevel[player] < levelThresholds.length &&
            playerXP[player] >= levelThresholds[playerLevel[player] - 1]
        ) {
            playerLevel[player]++;
            emit LevelUp(player, playerLevel[player]);
        }
    }

    function createChallenge(address opponent) public nonReentrant onlyPlayer {
        require(msg.sender != opponent, "Cannot challenge yourself");
        require(
            playerWeapons[msg.sender].length > 0,
            "You need at least one weapon to challenge"
        );

        playerChallenges[msg.sender] = opponent;
        challengeExpiry[opponent] = block.timestamp + 1 days;

        playerStats[msg.sender].challengesIssued++;

        emit ChallengeCreated(msg.sender, opponent);
    }

    function acceptChallenge() public nonReentrant onlyPlayer {
        address challenger = playerChallenges[msg.sender];
        require(challenger != address(0), "No challenge available");
        require(
            block.timestamp <= challengeExpiry[msg.sender],
            "Challenge has expired"
        );

        uint256 challengerPower = calculatePower(challenger);
        uint256 opponentPower = calculatePower(msg.sender);

        address winner = challengerPower > opponentPower
            ? challenger
            : msg.sender;
        kings.mint(winner, 100);

        playerStats[winner].wins++;
        playerStats[winner == challenger ? msg.sender : challenger].losses++;

        addXP(winner, 50);

        emit ChallengeAccepted(challenger, msg.sender, winner, 100);

        playerChallenges[msg.sender] = address(0);
    }

    function calculatePower(address player) internal view returns (uint256) {
        uint256 totalPower = 0;
        for (uint256 i = 0; i < playerWeapons[player].length; i++) {
            totalPower += weapons[playerWeapons[player][i]].power;
        }
        return totalPower + randomFactor();
    }

    function declineChallenge() public nonReentrant onlyPlayer {
        address challenger = playerChallenges[msg.sender];
        require(challenger != address(0), "No challenge available");

        rejectedChallenges[msg.sender]++;
        uint256 penalty = 10 * rejectedChallenges[msg.sender]; 
        kings.transferFrom(msg.sender, address(this), penalty);

        emit ChallengeDeclined(challenger, msg.sender, penalty);

        playerChallenges[msg.sender] = address(0);
    }

    function randomFactor() internal view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
            ) % 100;
    }

    function getPlayerDetails(
        address player
    )
        public
        view
        returns (
            uint256 stakeAmount,
            uint256 stakeStartTime,
            uint256 level,
            uint256 xp,
            uint256 taxAccumulated,
            uint256 totalReward,
            uint256[] memory weaponIds, 
            PlayerStats memory stats
        )
    {
        stakeAmount = stakes[player];
        stakeStartTime = stakeTime[player];
        level = playerLevel[player];
        xp = playerXP[player];
        taxAccumulated = playerTaxes[player];
        totalReward = totalRewards[player];
        weaponIds = playerWeapons[player];
        stats = playerStats[player];
    }

    function updateWeaponPrice(
        uint256 weaponId,
        uint256 newPrice
    ) public onlyOwner {
        require(weapons[weaponId].price > 0, "Weapon does not exist");
        weapons[weaponId].price = newPrice;
    }

    function addWeapon(
        uint256 weaponId,
        uint256 power,
        uint256 price
    ) public onlyOwner {
        require(weapons[weaponId].price == 0, "Weapon already exists");
        weapons[weaponId] = Weapon({power: power, price: price});
    }

    function updateLevelThresholds(
        uint256[] memory newThresholds
    ) public onlyOwner {
        require(newThresholds.length > 0, "Thresholds cannot be empty");
        levelThresholds = newThresholds;
    }

    function getPlayerWeapons(
        address player
    ) public view returns (uint256[] memory) {
        uint256[] memory ownedWeapons = playerWeapons[player];
        return ownedWeapons;
    }

    function applyRejectionPenalty(address player) internal {
        uint256 rejectionCount = rejectedChallenges[player];
        uint256 penalty = rejectionCount * 10; 
        require(
            kings.balanceOf(player) >= penalty,
            "Insufficient balance for penalty"
        );
        kings.transferFrom(player, address(this), penalty);
    }

    function distributeTaxesAutomatically() public onlyOwner {
        uint256 totalTaxAmount = 0;

        for (uint256 i = 0; i < players.length; i++) {
            address player = players[i];
            uint256 playerTax = (stakes[player] * taxRate) / 100;
            playerTaxes[player] += playerTax;
            totalTaxAmount += playerTax;
        }

        emit TaxDistributed(totalTaxAmount);
    }

    function withdrawTokens(address token, uint256 amount) public onlyOwner {
        IERC20(token).transfer(owner, amount);
    }

    fallback() external payable {
        revert("Contract does not accept Ether");
    }

    function cleanUpChallenges(address player) internal {
        playerChallenges[player] = address(0);
        challengeExpiry[player] = 0;
    }

    function getAllPlayers() public view returns (address[] memory) {
        return players;
    }

    function isRegistered(address player) public view returns (bool) {
        return isPlayer[player];
    }
}
