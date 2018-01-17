local Const =
{
	ResGold = 1,
	ResBuilder = 3,
	ResCrystal = 4,
	ResSpecial = 5,
	ResExp = 6,
	ResScore = 7,
	ResZhanhun = 8,
	ResMagic = 9,
	ResMedicine = 10,
	ResBeercup = 11,
    ResEventMoney = 15,
    ResMicCrystal = 26,
    ResTrials = 27,
    ResPBead = 28,
    ResGXun = 32,
    ResGaStone = 52,

	InfoName = 0,
	InfoSynTime = 1,
	InfoScore = 2,
	InfoPurchase = 3,
	InfoUglv = 4,
	InfoLevel = 5,     --领主等级
	InfoExp = 6,
	InfoFlag = 7,
	InfoLayout = 8,
    InfoRandom = 9,
    InfoTownLv = 10,
    InfoWeaponLv = 11,
    InfoHead = 12,
    InfoVIPlv = 13,
    InfoVIPexp = 14,
    InfoNewer = 15,
    InfoPush = 16,
    InfoSVid = 17,
    InfoPopCode = 18,

	ItemEquipPart = 1,
    ItemEquipStone = 2,
    ItemResBox = 3,
    ItemAccObj = 4,
    ItemHWater = 5,
    ItemOther = 6,
    ItemFragment = 7,
    ItemEquipFrag = 8,
    ItemHero = 9,
    ItemRes = 10,
    ItemEquip = 11,
    ItemPvtSkill = 12,

    ProShield = 0,
    ProGold = 1,
    ProGoldMax = 2,
    ProBuilder = 3,
    ProCrystal = 4,
    ProSpecial = 5,
    ProRegTime = 6,
    ProGuide = 7,
    ProZhanhun = 8,
    ProMagic = 9,
    ProMedicine = 10,
    ProBeercup = 11,
	ProBuilderMax = 12,
	ProFreeTime = 13,
	ProHeroNum = 14,
    ProEventMoney = 15,
    ProLuck = 20,
    ProLuckCount = 21,
    ProLuckReward = 22,
    ProMicCrystal = 26,
    ProTrials = 27,
    ProPBead = 28,
    ProPetTime = 30,
    ProPetNum = 31,
    ProGXun = 32,
    ProLBox = 33,
    ProDJCount = 34,
    ProDJTime = 35,
    ProObsTime = 36,
    ProRenameCount = 41,
    ProMonthCard = 50,       --联盟月卡
    ProGaEnery = 51,         --炼金能量
    ProGaStone = 52,         --炼金石
    ProGaTime = 53,          --炼金时间
    ProOnlineTime = 54,       --在线时间
    ProOnlineCount = 55,      --在线领取次数
    ProWorshipTime = 56,    --膜拜时间
    ProBuySgin = 57,       --是否充值
    ProUseLayout = 70,       --是否启用阵容

    LayoutPvp = 10,     --防守阵容
    LayoutPvc = 20,     --竞技场
    LayoutPvh = 30,     --远征
    LayoutPvtAtk = 50,  --试炼
    LayoutPvtDef = 60,  --试炼
    LayoutPve = 70,     --剧情战 掠夺战 联盟战
    LayoutUPve = 80,     --联盟副本

    BattleTypePvp = 1, --个人PVP
    BattleTypePve = 2, --个人PVE
    BattleTypePvc = 3, --竞技场
    BattleTypePvh = 4, --英雄远征
    BattleTypePvt = 5, --英雄试炼
    BattleTypePvj = 6, --僵尸来袭
    BattleTypeUPve = 7, --联盟副本
    BattleTypeUPvp = 8, --联盟战

    VisitTypeUn = 101, --联盟中参观

	Town = 1,
	BuilderRoom = 11,
	GoldStorage = 12,
	GoldProducer = 13,
    HeroBase = 3,
    WeaponBase = 4,
    ArenaBase = 5,
    EquipBase = 6,
    Wall = 50,

    InitTime = 1458259200,
    RdM = 65536,
    RdA = 12347,
    RdB = 20809,
    MaxHeroLevel = 200,
    InitHeroLevel = 120,
    MaxMainSkillLevel = 20,
    MaxAwakeLevel = 12,
    MaxSoldierLevel = 50,
    MaxSoldierSkillLevel = 5,
    InitHeroNum = 30,
    MaxHeroNum = 200,
    PriceHeroNum = 50,
    PriceRename = 1000,
    PriceEquip = 5000,
    PriceEpartRefresh = {20,50,100},
    PriceTrialsRefresh = {10,30,50,50,50,100,100,100,200,200,200,400,400,400,800,800,800,1600},
    BSkillMinHLevel = 10,
    BSkillFirstCost = 300,
    BSkillRefreshCost = 200,
    BSkillLightCost = {200,300,400,500,600,700,800,900},
    LuckyLotteryCost = {0,200,300,400},
    LuckyLotteryBase = {5,50,100,150},
    HelpUnlockLevel = {3, 5, 17},
    MaxWeaponNum = 4,
    PvpCost = {5,25,50,75,100,200,350,550,750,1000},
    ShieldSetting = {{0,7200,86400},{100,86400,86400*5},{150,86400*2,86400*10},{250,86400*7,86400*35}},
    MaxArenaChance = 5,
    MaxArenaLevel = 24,
    MaxArenaBuy = 3,
    PveTime = 7200,
    MaxPveChance = 5,
    MaxPveBuyChance = 2,
    PveChancePrice = {200,500},
    PriceInspire = 80,
    InspireEffect = 8,
    MaxInspireNum = 5,
    PvhExps = {90,156,214,321,446,578,723,898,1364,1874},
    ProduceBoostTime = 21600,
    ProduceBoostRate = 2,
    HeroStarLevel = 5,
    MaxEquipNum = 100,
    MaxUPMSkillLevel = 20,
    MaxUPBSkillLevel = 12,
    MaxUPTSkillLevel = 8,
    MaxUPGoldChance = 10,
    PriceUPGold = 100000,
    PriceUPCrystal = 200,
    UPGetByGold = 6,
    UPBoxByGold = 1,
    UPGetByCrystal = 200,
    UPBoxByCrystal = 4,
    MaxUPBoxExp = 20,
    MaxUPBoxNum = 100,
    MaxPvjPoint = 240,
    PvjPointTime = 360,
    EquipFragMerge = 50,
    BaseDJSpecial = 10,
    BaseDJZhanhun = 500,
    PriceDJCrystal = 50,
    RatesDJBeercup = {2000,1000,500,200,50},
    RatesDJCrystal = {0,15000,10000,5000,2000,1800,1600,1400,1000,600,500,400,300,200,100,60,40,20,10,5},
    RatesGroupDJCrystal = {{5,2,10},{10,4,12},{15,6,14},{20,8,16},{0,10,20}},
    GXunByPBead = 20,
    
    CmdUpgradeUlv = 1,
    CmdChangeLayout = 2,
    CmdBuyHeroPlace = 3,
    CmdBuyRes = 4,
    CmdTestBuyCrystal = 5,
    CmdAddGuideStep = 6,

    CmdUpgradeWeapon = 11,
    CmdProduceWeapon = 12,
    CmdCancelWeapon = 13,
    CmdAccWeapon = 14,
    CmdFinishWeapon = 15,

    CmdBatchLayouts = 101,
    CmdBatchExts = 102,
    CmdBuyBuild = 103,
    CmdUpgradeBuild = 104,
    CmdUpgradeBuildOver = 105,
    CmdCancelBuild = 106,
    CmdAccBuild = 107,
    CmdCollectRes = 108,
    CmdUpgradeArmor = 109,
    CmdAccBuildItem = 110,
    CmdBoostBuild = 111,
    CmdBoostOver = 112,
    CmdRemoveBuild = 113,
    CmdSellBuild = 114,
    CmdRemoveObstacle = 115,
    CmdFinishRemove = 116,
    CmdInitObstacle = 117,

    CmdLuckyLottery = 151,
    CmdLuckyReward = 152,
    CmdUseOrSellItem = 153,
    CmdBeerGet = 154,

    CmdHeroLock = 200,
    CmdHeroUpgrade = 201,
    CmdHeroExplain = 202,
    CmdHeroMerge = 203,
    CmdHeroAwake = 204,
    CmdHeroUpgradeMain = 205,
    CmdHeroChangeBSkill = 206,
    CmdHeroUpgradeSoldier = 208,
    CmdHeroUpgradeSSkill = 209,
    CmdHeroDelete = 210,
    CmdHeroLayout = 211,
    CmdHeroMic = 212,
    CmdHeroBuy = 213,
    CmdHeroHeal = 214,
    CmdUseLayout = 215,

    CmdEquipBuy = 250,
    CmdEquipChange = 251,
    CmdEquipUpgrade = 252,
    CmdEquipInstall = 253,
    CmdEquipLvup = 254,
    CmdEquipMerge = 255,
    CmdEquipSell = 256,
    CmdShopEpart = 300,

    CmdPveReset = 310,
    CmdPveBBat = 311,

    CmdPvjGift = 320,
    CmdPvjBShop = 321,
    CmdPvjReset = 322,

    CmdPvhHSet = 330,
    CmdPvhInspire = 331,

    CmdClanJion = 340,
    CmdClanInvite = 341,
    CmdClanMMember = 342,
    CmdClanMClan = 343,

    CmdPvbABat = 350,
    CmdPvbBTimes = 351,
    CmdPvbReset = 352,

    CmdPvlSSet = 360,
    CmdPvlBBat = 361,
    CmdPvlLInto = 362,
    CmdPvlLSet = 363,
    CmdPvlAtker = 364,
    CmdPvlInspire = 365,

    CmdPvtSkill = 370,
    CmdPvtBTimes = 371,
    CmdPvtBShop = 372,
    CmdPvtBBat = 373,
    CmdPvtHSet = 374,

    CmdEmailDel = 380,
    CmdHeadChange = 381,
    CmdSetChange = 382,
    CmdMobaiReward = 383,
    CmdGiveMCard = 384,

    CmdActSHelp = 390,
    CmdActFHelp = 391,
    CmdActQNum = 392,
    CmdActExchange = 393,
    CmdActMoney = 394,
    CmdActOther = 395,

    CmdBShield = 400,

    CmdPvcBTimes = 410,

    CmdAlchemyBegin = 420,
    CmdAlchemyChance = 421,
    
    ASkillHp = 1,
    ASkillAtk = 2,
    ASkillGuard = 3,
    ASkillDef = 4,
    ASkillGod = 5,

    EmailRequestTime=5,    --邮件请求时间5分钟一次
    LogPlaybackTime=3,      --日志回放时间3天内
    LogMaxLength=99,
    RankUnionCupReward1=1500,--排行榜，金杯榜第一名奖励宝石数量
    RankUnionCupReward2=800,
    RankUnionCupReward3=500,

    PvhMaxTimes = 1,     --远征次数
    PvbHurtAddSet = {1,1,1,0.5,0.5,0.5,0.5,0.5}, --pvb好友助战
    NoticeCost = 100,    --联盟公告
    PvjStoreCost = {1680,5980,5980,5980,5980,5980,5980},
    DailyRobSet = {5000,10000,30000,50000,80000,120000,160000,200000,240000,280000,320000,360000,400000,440000,480000,520000},
    Qgiftset = {3000,10000,24000,50000,80000,120000,180000,250000},
    ChatCold = 60,
    ChatNum = 6,
    FacebookBoxSet = {2,6,8,12,16,20,24,28,32},
    HeroTrialLimit = 8,
    UPvpTimes = 3,  --联盟战次数
    TrialCGTimes = 3, --试炼挑战次数
    TrialBuyTimes = 3, --购买次数
}

return Const







