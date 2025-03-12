// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title GunZSQLiteDatabase
 * @notice A Solidity contract that attempts to replicate the essential
 *         schema and logic from the provided SQLite database example.
 *         This is for demonstration purposes only.
 *
 *         NOTE: Storing sensitive information (like passwords) and large BLOBs
 *         (like items/quest data) on-chain is typically not recommended for
 *         production usage due to cost, privacy, and security concerns.
 */
contract GunZSQLiteDatabase {
    // --------------------------------------------------------
    //                    SCHEMA STRUCTS
    // --------------------------------------------------------

    /**
     * @dev Mimics the Login table
     *      - AID: unique integer ID from Account
     *      - userID: unique user name
     *      - passwordData: text (in practice, do not store in plaintext!)
     *      - lastConnDate: store a timestamp or date string
     *      - lastIP: IP address string
     */
    struct Login {
        uint256 AID;
        string userID;
        string passwordData;
        string lastConnDate;
        string lastIP;
    }

    /**
     * @dev Mimics the Account table
     *      - AID: integer primary key
     *      - userID: unique user name
     *      - uGradeID, pGradeID: user grading
     *      - email: user email
     *      - regDate: registration timestamp
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
     * @dev Mimics the Character table
     *      We omit some columns or store them as strings/bytes for brevity.
     *      - CID: integer primary key
     *      - AID: foreign key to Account
     *      - name: character name
     *      - level, sex, xp, bp, hair, face, charNum, etc.
     *      - items, questItemInfo, etc. stored as bytes
     *      - timestamps stored as block timestamp or strings
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
        bytes items; // BLOB placeholder
        bytes questItemInfo; // BLOB placeholder
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
     * @dev Mimics the CharacterMakingLog table
     */
    struct CharacterMakingLog {
        uint256 id;
        uint256 AID;
        string charName;
        string logType; // Type text
        uint256 date;
    }

    /**
     * @dev Mimics the ClanGameLog table
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
     * @dev Mimics the CharacterItem table
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
     * @dev Mimics the Clan table
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
     * @dev Mimics the ClanMember table
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
     * @dev Mimics the Friend table
     */
    struct FriendData {
        uint256 id;
        uint256 CID;
        uint256 friendCID;
        uint256 friendType;
        uint256 favorite;
        bool deleteFlag;
    }

    // --------------------------------------------------------
    //                  STORAGE MAPPINGS
    // --------------------------------------------------------

    // We keep separate counters for each table's primary key.

    uint256 private loginCounter;
    uint256 private accountCounter;
    uint256 private characterCounter;
    uint256 private charMakingLogCounter;
    uint256 private clanGameLogCounter;
    uint256 private characterItemCounter;
    uint256 private clanCounter;
    uint256 private clanMemberCounter;
    uint256 private friendCounter;

    mapping(uint256 => Login) public logins; // key = pk (artificial)
    mapping(uint256 => Account) public accountsMap; // key = pk (AID)
    mapping(uint256 => Character) public charactersMap; // key = pk (CID)
    mapping(uint256 => CharacterMakingLog) public characterMakingLogs; // key = pk
    mapping(uint256 => ClanGameLog) public clanGameLogs; // key = pk
    mapping(uint256 => CharacterItem) public characterItems; // key = pk
    mapping(uint256 => Clan) public clansMap; // key = pk (CLID)
    mapping(uint256 => ClanMember) public clanMembers; // key = pk
    mapping(uint256 => FriendData) public friendsMap; // key = pk

    // --------------------------------------------------------
    //                         EVENTS
    // --------------------------------------------------------

    // Example events for each table
    event LoginCreated(uint256 indexed id, uint256 indexed AID, string userID);
    event AccountCreated(uint256 indexed AID, string userID);
    event CharacterCreated(uint256 indexed CID, uint256 indexed AID, string name);
    event ClanCreated(uint256 indexed CLID, string name, uint256 masterCID);
    event ClanMemberCreated(uint256 indexed CMID, uint256 indexed CLID, uint256 indexed CID);
    event CharacterItemCreated(uint256 indexed CIID, uint256 indexed CID, uint256 itemID);

    // --------------------------------------------------------
    //                  TABLE CRUD FUNCTIONS
    // --------------------------------------------------------

    // ---------- Login Table ----------

    function createLogin(
        uint256 _AID,
        string memory _userID,
        string memory _passwordData,
        string memory _lastIP
    ) public returns (uint256) {
        loginCounter++;
        logins[loginCounter] = Login({
            AID: _AID,
            userID: _userID,
            passwordData: _passwordData,
            lastConnDate: "", // can fill or update later
            lastIP: _lastIP
        });
        emit LoginCreated(loginCounter, _AID, _userID);
        return loginCounter;
    }

    function updateLoginLastConnDate(uint256 _loginID, string memory _date, string memory _ip) public {
        Login storage ln = logins[_loginID];
        ln.lastConnDate = _date;
        ln.lastIP = _ip;
    }

    // ---------- Account Table ----------

    function createAccount(
        string memory _userID,
        uint256 _uGradeID,
        uint256 _pGradeID,
        string memory _email
    ) public returns (uint256) {
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

    function banAccount(uint256 _AID) public {
        // set userGrade to a large number representing ban
        Account storage acc = accountsMap[_AID];
        acc.uGradeID = 9999;
    }

    // ---------- Character Table ----------

    function createCharacter(
        uint256 _AID,
        string memory _name,
        uint256 _sex,
        uint256 _charNum
    ) public returns (uint256) {
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

    function updateCharacterLevel(uint256 _CID, uint256 _newLevel) public {
        charactersMap[_CID].level = _newLevel;
    }

    function banCharacter(uint256 _CID) public {
        // set deleteFlag, for example
        charactersMap[_CID].deleteFlag = true;
    }

    // ---------- CharacterMakingLog Table ----------

    function insertCharacterMakingLog(
        uint256 _AID,
        string memory _charName,
        string memory _type
    ) public returns (uint256) {
        charMakingLogCounter++;
        characterMakingLogs[charMakingLogCounter] = CharacterMakingLog({
            id: charMakingLogCounter,
            AID: _AID,
            charName: _charName,
            logType: _type,
            date: block.timestamp
        });
        return charMakingLogCounter;
    }

    // ---------- Clan Table ----------

    function createClan(string memory _name, uint256 _masterCID) public returns (uint256) {
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

    function deleteClan(uint256 _CLID, string memory _deleteName) public {
        Clan storage cl = clansMap[_CLID];
        cl.deleteFlag = true;
        cl.deleteName = _deleteName;
        // optionally set name to empty
        // cl.name = "";
    }

    // ---------- ClanMember Table ----------

    function addClanMember(
        uint256 _CLID,
        uint256 _CID,
        uint256 _grade
    ) public returns (uint256) {
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

    // ---------- ClanGameLog Table ----------

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
    ) public returns (uint256) {
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
        return clanGameLogCounter;
    }

    // ---------- CharacterItem Table ----------

    function insertCharacterItem(
        uint256 _CID,
        uint256 _itemID,
        uint256 _rentHourPeriod,
        uint256 _cnt
    ) public returns (uint256) {
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

    // ---------- Friend Table ----------

    function addFriend(
        uint256 _CID,
        uint256 _friendCID,
        uint256 _friendType,
        uint256 _favorite
    ) public returns (uint256) {
        friendCounter++;
        friendsMap[friendCounter] = FriendData({
            id: friendCounter,
            CID: _CID,
            friendCID: _friendCID,
            friendType: _friendType,
            favorite: _favorite,
            deleteFlag: false
        });
        return friendCounter;
    }

    function removeFriend(uint256 _friendID) public {
        friendsMap[_friendID].deleteFlag = true;
    }

    // Additional update/CRUD methods can be created as needed.
    // This contract is a simplistic demonstration and does not include
    // robust access controls, transaction atomicity, or advanced logic.
    // Use caution when adapting to a real environment!
}
