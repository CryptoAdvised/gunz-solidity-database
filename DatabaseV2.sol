// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title GunZDatabase
 * @notice A large, demonstration-only contract that attempts to replicate.
 */

import "@openzeppelin/contracts/access/Ownable.sol";

contract GunZDatabase is Ownable {
    // =========================================================
    //                       TABLE STRUCTS
    // =========================================================

    /**
     * @dev Represents the 'Login' table
     */
    struct Login {
        uint256 AID;
        string userID;
        string passwordData;
        string lastConnDate;
        string lastIP;
    }

    /**
     * @dev Represents the 'Account' table
     */
    struct Account {
        uint256 AID;
        string userID;
        uint256 uGradeID;
        uint256 pGradeID;
        string email;
        uint256 regDate;
    }

    /**
     * @dev Represents the 'Character' table
     */
    struct Character {
        uint256 CID;
        uint256 AID;
        string name;
        uint256 level;
        uint256 sex;
        uint256 charNum;
        uint256 hair;
        uint256 face;
        uint256 xp;
        uint256 bp;
        bytes items;             // BLOB placeholder
        bytes questItemInfo;     // BLOB placeholder
        uint256 regDate;
        uint256 lastTime;
        uint256 playTime;
        uint256 gameCount;
        uint256 killCount;
        uint256 deathCount;
        bool deleteFlag;
        string deleteName;
    }

    /**
     * @dev Represents the 'CharacterMakingLog' table
     */
    struct CharacterMakingLog {
        uint256 id;
        uint256 AID;
        string charName;
        string logType;
        uint256 date;
    }

    /**
     * @dev Represents the 'ClanGameLog' table
     */
    struct ClanGameLog {
        uint256 id;
        uint256 winnerCLID;
        uint256 loserCLID;
        string winnerClanName;
        string loserClanName;
        uint256 roundWins;
        uint256 roundLosses;
        string mapID;
        uint256 gameType;
        uint256 regDate;
        string winnerMembers;
        string loserMembers;
        int256 winnerPoint;
        int256 loserPoint;
    }

    /**
     * @dev Represents the 'CharacterItem' table
     */
    struct CharacterItem {
        uint256 CIID;
        uint256 CID;
        uint256 itemID;
        uint256 regDate;
        uint256 rentDate;
        uint256 rentHourPeriod;
        uint256 cnt;
    }

    /**
     * @dev Represents the 'Clan' table
     */
    struct Clan {
        uint256 CLID;
        string name;
        uint256 exp;
        uint256 level;
        int256 point;
        uint256 masterCID;
        uint256 wins;
        string markWebImg;
        string introduction;
        uint256 regDate;
        bool deleteFlag;
        string deleteName;
        string homepage;
        uint256 losses;
        uint256 draws;
        uint256 ranking;
        int256 totalPoint;
        string cafeUrl;
        string email;
        string emblemUrl;
        uint256 rankIncrease;
        uint256 emblemChecksum;
        uint256 lastDayRanking;
        uint256 lastMonthRanking;
    }

    /**
     * @dev Represents the 'ClanMember' table
     */
    struct ClanMember {
        uint256 CMID;
        uint256 CLID;
        uint256 CID;
        uint256 grade;
        uint256 regDate;
        int256 contPoint;
    }

    /**
     * @dev Represents the 'Friend' table
     */
    struct FriendData {
        uint256 id;
        uint256 CID;
        uint256 friendCID;
        uint256 friendType;
        uint256 favorite;
        bool deleteFlag;
    }

    /**
     * @dev Represents the 'Blocks' table (ban records)
     */
    struct BlockData {
        uint256 blockID;
        uint256 AID;
        uint256 blockType; // e.g. 1 = banned
        string reason;
        uint256 endDate;
    }

    /**
     * @dev Represents a possible 'AccountItem' table (for storing items owned by accounts, not chars)
     */
    struct AccountItem {
        uint256 AIID;
        uint256 AID;
        uint256 itemID;
        uint256 regDate;
        uint256 rentDate;
        uint256 rentHourPeriod;
        uint256 cnt;
    }

    /**
     * @dev Represents logs that were mentioned but not explicitly in the code snippet:
     *      - KillLog
     *      - ChatLog
     *      - GameLog
     *      - ConnLog
     *      - ServerLog
     *      - PlayerLog
     *  We'll define minimal versions here.
     */
    struct KillLog {
        uint256 id;
        uint256 attackerCID;
        uint256 victimCID;
        uint256 timestamp;
    }

    struct ChatLog {
        uint256 id;
        uint256 CID;
        string message;
        uint256 timestamp;
    }

    struct GameLog {
        uint256 id;
        string gameName;
        string mapName;
        string gameType;
        uint256 round;
        uint256 masterCID;
        uint256 playerCount;
        string players;
        uint256 timestamp;
    }

    struct ConnLog {
        uint256 id;
        uint256 AID;
        string ip;
        string countryCode3;
        uint256 timestamp;
    }

    struct ServerLog {
        uint256 id;
        uint256 serverID;
        uint256 playerCount;
        uint256 gameCount;
        uint256 blockCount;
        uint256 nonBlockCount;
        uint256 timestamp;
    }

    struct PlayerLog {
        uint256 id;
        uint256 CID;
        uint256 playTime;
        uint256 killCount;
        uint256 deathCount;
        uint256 xp;
        uint256 totalXP;
        uint256 timestamp;
    }

    // =========================================================
    //                     PRIMARY KEYS
    // =========================================================

    uint256 private loginCounter;
    uint256 private accountCounter;
    uint256 private characterCounter;
    uint256 private charMakingLogCounter;
    uint256 private clanGameLogCounter;
    uint256 private characterItemCounter;
    uint256 private clanCounter;
    uint256 private clanMemberCounter;
    uint256 private friendCounter;
    uint256 private blockCounter;
    uint256 private accountItemCounter;

    // Additional log counters:
    uint256 private killLogCounter;
    uint256 private chatLogCounter;
    uint256 private gameLogCounter;
    uint256 private connLogCounter;
    uint256 private serverLogCounter;
    uint256 private playerLogCounter;

    // =========================================================
    //                    TABLE MAPPINGS
    // =========================================================

    mapping(uint256 => Login) public logins;
    mapping(uint256 => Account) public accountsMap;
    mapping(uint256 => Character) public charactersMap;
    mapping(uint256 => CharacterMakingLog) public characterMakingLogs;
    mapping(uint256 => ClanGameLog) public clanGameLogs;
    mapping(uint256 => CharacterItem) public characterItems;
    mapping(uint256 => Clan) public clansMap;
    mapping(uint256 => ClanMember) public clanMembers;
    mapping(uint256 => FriendData) public friendsMap;
    mapping(uint256 => BlockData) public blocksMap;
    mapping(uint256 => AccountItem) public accountItems;

    // Additional logs:
    mapping(uint256 => KillLog) public killLogs;
    mapping(uint256 => ChatLog) public chatLogs;
    mapping(uint256 => GameLog) public gameLogs;
    mapping(uint256 => ConnLog) public connLogs;
    mapping(uint256 => ServerLog) public serverLogs;
    mapping(uint256 => PlayerLog) public playerLogs;

    // =========================================================
    //                        EVENTS
    // =========================================================

    event LoginCreated(uint256 indexed id, uint256 indexed AID, string userID);
    event AccountCreated(uint256 indexed AID, string userID);
    event CharacterCreated(uint256 indexed CID, uint256 indexed AID, string name);
    event CharacterMakingLogInserted(uint256 indexed id, uint256 AID);
    event ClanGameLogInserted(uint256 indexed id, uint256 winnerCLID, uint256 loserCLID);
    event CharacterItemCreated(uint256 indexed CIID, uint256 indexed CID, uint256 itemID);
    event ClanCreated(uint256 indexed CLID, string name, uint256 masterCID);
    event ClanMemberCreated(uint256 indexed CMID, uint256 indexed CLID, uint256 indexed CID);
    event FriendAdded(uint256 indexed id, uint256 CID, uint256 friendCID);
    event BlockInserted(uint256 indexed blockID, uint256 indexed AID, uint256 blockType);
    event AccountItemCreated(uint256 indexed AIID, uint256 AID, uint256 itemID);

    // Additional logs:
    event KillLogInserted(uint256 indexed id, uint256 attackerCID, uint256 victimCID);
    event ChatLogInserted(uint256 indexed id, uint256 CID, string msg);
    event GameLogInserted(uint256 indexed id, string gameName, string map, string gameType);
    event ConnLogInserted(uint256 indexed id, uint256 AID, string ip, string country);
    event ServerLogInserted(uint256 indexed id, uint256 serverID);
    event PlayerLogInserted(uint256 indexed id, uint256 CID);

    // =========================================================
    //                    LOGIN FUNCTIONS
    // =========================================================

    /**
     * @dev Creates a new Login record. Only the contract owner can do this.
     */
    function createLogin(
        uint256 _AID,
        string memory _userID,
        string memory _passwordData,
        string memory _lastIP
    ) external onlyOwner returns (uint256) {
        loginCounter++;
        logins[loginCounter] = Login({
            AID: _AID,
            userID: _userID,
            passwordData: _passwordData,
            lastConnDate: "",
            lastIP: _lastIP
        });
        emit LoginCreated(loginCounter, _AID, _userID);
        return loginCounter;
    }

    function updateLoginLastConnDate(
        uint256 _loginID,
        string memory _date,
        string memory _ip
    ) external onlyOwner {
        Login storage ln = logins[_loginID];
        ln.lastConnDate = _date;
        ln.lastIP = _ip;
    }

    // =========================================================
    //                   ACCOUNT FUNCTIONS
    // =========================================================

    function createAccount(
        string memory _userID,
        uint256 _uGradeID,
        uint256 _pGradeID,
        string memory _email
    ) external onlyOwner returns (uint256) {
        accountCounter++;
        accountsMap[accountCounter] = Account({
            AID: accountCounter,
            userID: _userID,
            uGradeID: _uGradeID,
            pGradeID: _pGradeID,
            email: _email,
            regDate: block.timestamp
        });
        emit AccountCreated(accountCounter, _userID);
        return accountCounter;
    }

    /**
     * @dev Simple ban function sets uGradeID to 9999, also inserts a block record.
     */
    function banPlayer(
        uint256 _AID,
        uint256 _blockType,
        string memory _reason,
        uint256 _endDate
    ) external onlyOwner {
        // Mark the account as blocked
        accountsMap[_AID].uGradeID = 9999;

        // Insert a new block record
        blockCounter++;
        blocksMap[blockCounter] = BlockData({
            blockID: blockCounter,
            AID: _AID,
            blockType: _blockType,
            reason: _reason,
            endDate: _endDate
        });
        emit BlockInserted(blockCounter, _AID, _blockType);
    }

    /**
     * @dev Example of an event-based 'Jjang' or star upgrade
     */
    function eventJjangUpdate(uint256 _AID, bool _jjang) external onlyOwner {
        if (_jjang) {
            accountsMap[_AID].uGradeID = 7777; // 'star' example
        } else {
            accountsMap[_AID].uGradeID = 0;    // revert to free
        }
    }

    /**
     * @dev Example of checking premium IP - here it's just a stub returning true
     */
    function checkPremiumIP(string memory _ip) external pure returns (bool) {
        // Real logic would have a lookup or set of known IPs
        if (bytes(_ip).length > 0) {
            return true;
        }
        return false;
    }

    /**
     * @dev Let admin set or reset block type for an account
     */
    function setBlockAccount(
        uint256 _AID,
        uint8 _blockType,
        string memory _comment,
        string memory _ip,
        uint256 _endDate
    ) external onlyOwner {
        // create or update block record
        blockCounter++;
        blocksMap[blockCounter] = BlockData({
            blockID: blockCounter,
            AID: _AID,
            blockType: _blockType,
            reason: _comment,
            endDate: _endDate
        });
        // also set the account as blocked
        accountsMap[_AID].uGradeID = 9999;
    }

    function resetAccountBlock(uint256 _AID) external onlyOwner {
        accountsMap[_AID].uGradeID = 0;
    }

    function adminResetAllHackingBlock() external onlyOwner {
        // For demonstration only: in real usage, you'd iterate or store data differently
        // This might be a heavy operation on-chain. Not recommended for real usage.
    }

    // =========================================================
    //                  CHARACTER FUNCTIONS
    // =========================================================

    function createCharacter(
        uint256 _AID,
        string memory _name,
        uint256 _sex,
        uint256 _charNum
    ) external onlyOwner returns (uint256) {
        characterCounter++;
        charactersMap[characterCounter] = Character({
            CID: characterCounter,
            AID: _AID,
            name: _name,
            level: 1,
            sex: _sex,
            charNum: _charNum,
            hair: 0,
            face: 0,
            xp: 0,
            bp: 0,
            items: "",
            questItemInfo: "",
            regDate: block.timestamp,
            lastTime: 0,
            playTime: 0,
            gameCount: 0,
            killCount: 0,
            deathCount: 0,
            deleteFlag: false,
            deleteName: ""
        });
        emit CharacterCreated(characterCounter, _AID, _name);
        return characterCounter;
    }

    function updateCharacterLevel(uint256 _CID, uint256 _newLevel) external onlyOwner {
        charactersMap[_CID].level = _newLevel;
    }

    function setCharacterDeleteFlag(uint256 _CID, string memory _deleteName) external onlyOwner {
        Character storage chr = charactersMap[_CID];
        chr.deleteFlag = true;
        chr.deleteName = _deleteName;
    }

    function deleteCharacter(uint256 _CID) external onlyOwner {
        // Hard-delete is not typical in many on-chain designs, but shown here as an example
        delete charactersMap[_CID];
    }

    /**
     * @dev We store quest item info as raw bytes. This function updates it.
     */
    function updateQuestItem(uint256 _CID, bytes memory _questData) external onlyOwner {
        charactersMap[_CID].questItemInfo = _questData;
    }

    /**
     * @dev Returns the quest item bytes for a character
     */
    function getCharQuestItemInfo(uint256 _CID) external view returns (bytes memory) {
        return charactersMap[_CID].questItemInfo;
    }

    // =========================================================
    //             CHARACTER MAKING LOG FUNCTIONS
    // =========================================================

    function insertCharacterMakingLog(
        uint256 _AID,
        string memory _charName,
        string memory _type
    ) external onlyOwner returns (uint256) {
        charMakingLogCounter++;
        characterMakingLogs[charMakingLogCounter] = CharacterMakingLog({
            id: charMakingLogCounter,
            AID: _AID,
            charName: _charName,
            logType: _type,
            date: block.timestamp
        });
        emit CharacterMakingLogInserted(charMakingLogCounter, _AID);
        return charMakingLogCounter;
    }

    // =========================================================
    //                 CLAN GAME LOG FUNCTIONS
    // =========================================================

    function insertClanGameLog(
        uint256 _winnerCLID,
        uint256 _loserCLID,
        string memory _winnerClanName,
        string memory _loserClanName,
        uint256 _roundWins,
        uint256 _roundLosses,
        string memory _mapID,
        uint256 _gameType,
        string memory _winnerMembers,
        string memory _loserMembers,
        int256 _winnerPoint,
        int256 _loserPoint
    ) external onlyOwner returns (uint256) {
        clanGameLogCounter++;
        clanGameLogs[clanGameLogCounter] = ClanGameLog({
            id: clanGameLogCounter,
            winnerCLID: _winnerCLID,
            loserCLID: _loserCLID,
            winnerClanName: _winnerClanName,
            loserClanName: _loserClanName,
            roundWins: _roundWins,
            roundLosses: _roundLosses,
            mapID: _mapID,
            gameType: _gameType,
            regDate: block.timestamp,
            winnerMembers: _winnerMembers,
            loserMembers: _loserMembers,
            winnerPoint: _winnerPoint,
            loserPoint: _loserPoint
        });
        emit ClanGameLogInserted(clanGameLogCounter, _winnerCLID, _loserCLID);
        return clanGameLogCounter;
    }

    // =========================================================
    //              CHARACTER ITEM FUNCTIONS
    // =========================================================

    function insertCharacterItem(
        uint256 _CID,
        uint256 _itemID,
        uint256 _rentHourPeriod,
        uint256 _cnt
    ) external onlyOwner returns (uint256) {
        characterItemCounter++;
        characterItems[characterItemCounter] = CharacterItem({
            CIID: characterItemCounter,
            CID: _CID,
            itemID: _itemID,
            regDate: block.timestamp,
            rentDate: 0,
            rentHourPeriod: _rentHourPeriod,
            cnt: _cnt
        });
        emit CharacterItemCreated(characterItemCounter, _CID, _itemID);
        return characterItemCounter;
    }

    function deleteCharItem(uint256 _CID, uint256 _CIID) external onlyOwner {
        // For demonstration, just set CID=0 or remove
        if (characterItems[_CIID].CID == _CID) {
            delete characterItems[_CIID];
        }
    }

    /**
     * @dev Example function to equip an item. Here, just store items as bytes in Character
     */
    function updateEquipedItem(uint256 _CID, bytes memory _newItemsBlob) external onlyOwner {
        charactersMap[_CID].items = _newItemsBlob;
    }

    function clearAllEquipedItem(uint256 _CID) external onlyOwner {
        charactersMap[_CID].items = "";
    }

    // =========================================================
    //                  ACCOUNT ITEM FUNCTIONS
    // =========================================================

    function insertAccountItem(
        uint256 _AID,
        uint256 _itemID,
        uint256 _rentHourPeriod,
        uint256 _cnt
    ) external onlyOwner returns (uint256) {
        accountItemCounter++;
        accountItems[accountItemCounter] = AccountItem({
            AIID: accountItemCounter,
            AID: _AID,
            itemID: _itemID,
            regDate: block.timestamp,
            rentDate: 0,
            rentHourPeriod: _rentHourPeriod,
            cnt: _cnt
        });
        emit AccountItemCreated(accountItemCounter, _AID, _itemID);
        return accountItemCounter;
    }

    /**
     * @dev Minimal logic for bringing an account item into a character’s inventory
     */
    function bringAccountItem(
        uint256 _AID,
        uint256 _CID,
        uint256 _AIID
    ) external onlyOwner returns (uint256) {
        AccountItem storage ai = accountItems[_AIID];
        require(ai.AID == _AID, "Wrong AID for account item");

        // Insert into CharacterItem as a new item
        characterItemCounter++;
        characterItems[characterItemCounter] = CharacterItem({
            CIID: characterItemCounter,
            CID: _CID,
            itemID: ai.itemID,
            regDate: block.timestamp,
            rentDate: ai.rentDate,
            rentHourPeriod: ai.rentHourPeriod,
            cnt: ai.cnt
        });

        // remove from the account item table
        delete accountItems[_AIID];
        return characterItemCounter;
    }

    // =========================================================
    //                     CLAN FUNCTIONS
    // =========================================================

    function createClan(string memory _name, uint256 _masterCID) external onlyOwner returns (uint256) {
        clanCounter++;
        clansMap[clanCounter] = Clan({
            CLID: clanCounter,
            name: _name,
            exp: 0,
            level: 1,
            point: 1000,
            masterCID: _masterCID,
            wins: 0,
            markWebImg: "",
            introduction: "",
            regDate: block.timestamp,
            deleteFlag: false,
            deleteName: "",
            homepage: "",
            losses: 0,
            draws: 0,
            ranking: 0,
            totalPoint: 0,
            cafeUrl: "",
            email: "",
            emblemUrl: "",
            rankIncrease: 0,
            emblemChecksum: 0,
            lastDayRanking: 0,
            lastMonthRanking: 0
        });
        emit ClanCreated(clanCounter, _name, _masterCID);
        return clanCounter;
    }

    function reserveCloseClan(uint256 _CLID, string memory _deleteName) external onlyOwner {
        clansMap[_CLID].deleteFlag = true;
        clansMap[_CLID].deleteName = _deleteName;
    }

    function closeClan(uint256 _CLID, string memory _clanName, uint256 _masterCID) external onlyOwner {
        Clan storage c = clansMap[_CLID];
        // Optionally check that c.name == _clanName and c.masterCID == _masterCID
        c.deleteFlag = true;
        c.deleteName = _clanName;
        c.name = "";
        c.masterCID = 0;
    }

    // =========================================================
    //              CLAN MEMBER FUNCTIONS
    // =========================================================

    function addClanMember(
        uint256 _CLID,
        uint256 _CID,
        uint256 _grade
    ) external onlyOwner returns (uint256) {
        clanMemberCounter++;
        clanMembers[clanMemberCounter] = ClanMember({
            CMID: clanMemberCounter,
            CLID: _CLID,
            CID: _CID,
            grade: _grade,
            regDate: block.timestamp,
            contPoint: 0
        });
        emit ClanMemberCreated(clanMemberCounter, _CLID, _CID);
        return clanMemberCounter;
    }

    function removeClanMember(uint256 _CLID, uint256 _CID) external onlyOwner {
        // For demonstration, find the matching ClanMember record
        for (uint256 i = 1; i <= clanMemberCounter; i++) {
            if (clanMembers[i].CLID == _CLID && clanMembers[i].CID == _CID) {
                delete clanMembers[i];
                break;
            }
        }
    }

    function updateClanGrade(uint256 _CLID, uint256 _CID, uint256 _newGrade) external onlyOwner {
        // For demonstration, find matching record
        for (uint256 i = 1; i <= clanMemberCounter; i++) {
            if (clanMembers[i].CLID == _CLID && clanMembers[i].CID == _CID) {
                clanMembers[i].grade = _newGrade;
                break;
            }
        }
    }

    /**
     * @dev Expel a clan member from a clan
     */
    function expelClanMember(uint256 _CLID, uint256 _CID) external onlyOwner {
        // Same logic as removeClanMember, except we might enforce a grade check
        for (uint256 i = 1; i <= clanMemberCounter; i++) {
            if (clanMembers[i].CLID == _CLID && clanMembers[i].CID == _CID) {
                delete clanMembers[i];
                break;
            }
        }
    }

    // =========================================================
    //                 FRIEND TABLE FUNCTIONS
    // =========================================================

    function addFriend(
        uint256 _CID,
        uint256 _friendCID,
        uint256 _friendType,
        uint256 _favorite
    ) external onlyOwner returns (uint256) {
        friendCounter++;
        friendsMap[friendCounter] = FriendData({
            id: friendCounter,
            CID: _CID,
            friendCID: _friendCID,
            friendType: _friendType,
            favorite: _favorite,
            deleteFlag: false
        });
        emit FriendAdded(friendCounter, _CID, _friendCID);
        return friendCounter;
    }

    function removeFriend(uint256 _friendID) external onlyOwner {
        friendsMap[_friendID].deleteFlag = true;
    }

    // =========================================================
    //                  BLOCKS TABLE FUNCTIONS
    // =========================================================

    function insertBlockRecord(
        uint256 _AID,
        uint256 _blockType,
        string memory _reason,
        uint256 _endDate
    ) external onlyOwner returns (uint256) {
        blockCounter++;
        blocksMap[blockCounter] = BlockData({
            blockID: blockCounter,
            AID: _AID,
            blockType: _blockType,
            reason: _reason,
            endDate: _endDate
        });
        emit BlockInserted(blockCounter, _AID, _blockType);
        return blockCounter;
    }

    // =========================================================
    //        BUY / SELL BOUNTY ITEM (DEMONSTRATION ONLY)
    // =========================================================

    /**
     * @dev Minimal approach:
     *      1) Check if character has enough BP to buy
     *      2) Deduct BP
     *      3) Insert a character item
     */
    function buyBountyItem(uint256 _CID, uint256 _itemID, uint256 _price) external onlyOwner returns (uint256) {
        Character storage c = charactersMap[_CID];
        require(c.bp >= _price, "Not enough BP");
        c.bp -= _price;
        // Insert item
        characterItemCounter++;
        characterItems[characterItemCounter] = CharacterItem({
            CIID: characterItemCounter,
            CID: _CID,
            itemID: _itemID,
            regDate: block.timestamp,
            rentDate: 0,
            rentHourPeriod: 0,
            cnt: 1
        });
        emit CharacterItemCreated(characterItemCounter, _CID, _itemID);
        return characterItemCounter;
    }

    /**
     * @dev Minimal approach:
     *      1) Remove item from the character
     *      2) Add BP
     */
    function sellBountyItem(uint256 _CID, uint256 _CIID, uint256 _price) external onlyOwner {
        CharacterItem storage ci = characterItems[_CIID];
        require(ci.CID == _CID, "Item not owned by this character");
        // remove item
        delete characterItems[_CIID];
        // add BP
        charactersMap[_CID].bp += _price;
    }

    // =========================================================
    //             ADDITIONAL LOGGING FUNCTIONS
    // =========================================================

    function insertKillLog(uint256 _attackerCID, uint256 _victimCID) external onlyOwner {
        killLogCounter++;
        killLogs[killLogCounter] = KillLog({
            id: killLogCounter,
            attackerCID: _attackerCID,
            victimCID: _victimCID,
            timestamp: block.timestamp
        });
        emit KillLogInserted(killLogCounter, _attackerCID, _victimCID);
    }

    function insertChatLog(uint256 _CID, string memory _msg) external onlyOwner {
        chatLogCounter++;
        chatLogs[chatLogCounter] = ChatLog({
            id: chatLogCounter,
            CID: _CID,
            message: _msg,
            timestamp: block.timestamp
        });
        emit ChatLogInserted(chatLogCounter, _CID, _msg);
    }

    function insertGameLog(
        string memory _gameName,
        string memory _map,
        string memory _gameType,
        uint256 _round,
        uint256 _masterCID,
        uint256 _playerCount,
        string memory _players
    ) external onlyOwner {
        gameLogCounter++;
        gameLogs[gameLogCounter] = GameLog({
            id: gameLogCounter,
            gameName: _gameName,
            mapName: _map,
            gameType: _gameType,
            round: _round,
            masterCID: _masterCID,
            playerCount: _playerCount,
            players: _players,
            timestamp: block.timestamp
        });
        emit GameLogInserted(gameLogCounter, _gameName, _map, _gameType);
    }

    function insertConnLog(
        uint256 _AID,
        string memory _ip,
        string memory _countryCode3
    ) external onlyOwner {
        connLogCounter++;
        connLogs[connLogCounter] = ConnLog({
            id: connLogCounter,
            AID: _AID,
            ip: _ip,
            countryCode3: _countryCode3,
            timestamp: block.timestamp
        });
        emit ConnLogInserted(connLogCounter, _AID, _ip, _countryCode3);
    }

    function insertServerLog(
        uint256 _serverID,
        uint256 _playerCount,
        uint256 _gameCount,
        uint256 _blockCount,
        uint256 _nonBlockCount
    ) external onlyOwner {
        serverLogCounter++;
        serverLogs[serverLogCounter] = ServerLog({
            id: serverLogCounter,
            serverID: _serverID,
            playerCount: _playerCount,
            gameCount: _gameCount,
            blockCount: _blockCount,
            nonBlockCount: _nonBlockCount,
            timestamp: block.timestamp
        });
        emit ServerLogInserted(serverLogCounter, _serverID);
    }

    function insertPlayerLog(
        uint256 _CID,
        uint256 _playTime,
        uint256 _killCount,
        uint256 _deathCount,
        uint256 _xp,
        uint256 _totalXP
    ) external onlyOwner {
        playerLogCounter++;
        playerLogs[playerLogCounter] = PlayerLog({
            id: playerLogCounter,
            CID: _CID,
            playTime: _playTime,
            killCount: _killCount,
            deathCount: _deathCount,
            xp: _xp,
            totalXP: _totalXP,
            timestamp: block.timestamp
        });
        emit PlayerLogInserted(playerLogCounter, _CID);
    }

    // =========================================================
    //               SIMPLE HELPER / GET FUNCTIONS
    // =========================================================

    /**
     * @dev Example function to retrieve a character’s clan ID and name
     *      (like GetCharClan in the snippet). This is a naive approach.
     */
    function getCharClan(uint256 _CID) external view returns (uint256 clanID, string memory clanName, bool found) {
        found = false;
        for (uint256 i = 1; i <= clanMemberCounter; i++) {
            if (clanMembers[i].CID == _CID) {
                clanID = clanMembers[i].CLID;
                clanName = clansMap[clanID].name;
                found = true;
                break;
            }
        }
    }

    /**
     * @dev Example function to get a clan ID by name
     */
    function getClanIDFromName(string memory _name) external view returns (uint256, bool) {
        for (uint256 i = 1; i <= clanCounter; i++) {
            if (keccak256(bytes(clansMap[i].name)) == keccak256(bytes(_name))) {
                return (i, true);
            }
        }
        return (0, false);
    }

    /**
     * @dev Example function to retrieve a character ID by name
     */
    function getCID(string memory _charName) external view returns (uint256, bool) {
        for (uint256 i = 1; i <= characterCounter; i++) {
            if (!charactersMap[i].deleteFlag && keccak256(bytes(charactersMap[i].name)) == keccak256(bytes(_charName))) {
                return (i, true);
            }
        }
        return (0, false);
    }

    /**
     * @dev Example function to retrieve a char's name by CID
     */
    function getCharName(uint256 _CID) external view returns (string memory) {
        if (charactersMap[_CID].deleteFlag) {
            return "";
        }
        return charactersMap[_CID].name;
    }

    /**
     * @dev Example function to retrieve an Account by AID
     */
    function getAccountInfo(uint256 _AID)
        external
        view
        returns (string memory userID, uint256 uGrade, string memory email)
    {
        Account storage acc = accountsMap[_AID];
        userID = acc.userID;
        uGrade = acc.uGradeID;
        email = acc.email;
    }

    /**
     * @dev Example function for partial usage in 'UpdateCharInfoData' style
     */
    function updateCharInfoData(
        uint256 _CID,
        uint256 _addedXP,
        uint256 _addedBP,
        uint256 _addedKills,
        uint256 _addedDeaths
    ) external onlyOwner {
        Character storage c = charactersMap[_CID];
        c.xp += _addedXP;
        c.bp += _addedBP;
        c.killCount += _addedKills;
        c.deathCount += _addedDeaths;
    }

    /**
     * @dev Example function to update total play time
     */
    function updateCharPlayTime(uint256 _CID, uint256 _playTime) external onlyOwner {
        charactersMap[_CID].playTime += _playTime;
        charactersMap[_CID].lastTime = block.timestamp;
    }

}
