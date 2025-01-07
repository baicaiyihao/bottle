/*
/// Module: bottle
module bottle::bottle;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions
module bottle::bottle{
    use std::string::String;
    use sui::random::Random;
    use sui::balance::Balance;
    use sui::coin::Coin;
    use sui::object;
    use sui::random;
    use sui::sui::SUI;
    use sui::table_vec::{Self, TableVec};
    use sui::transfer;

    //创建漂流瓶
    public struct RedpacketBottle has key{
        id: UID,
        message: String,
        coin: Balance<SUI>
    }

    //存储漂流瓶
    public struct RedpacketBottleList has key{
        id: UID,
        list: TableVec<RedpacketBottle>,
    }

    fun init(ctx: &mut TxContext){
        let redpacketbottle = RedpacketBottleList{
            id: object::new(ctx),
            list: TableVec<RedpacketBottle>::new()
        };

        transfer::share_object(redpacketbottle);
    }

    //创建无sui红包漂流瓶
    public fun createBottle(
        bottleList:&mut RedpacketBottleList,
        message: String,
        ctx:&mut TxContext
    ){
        let redpacketbottle = RedpacketBottle{
            id: object::new(ctx),
            message,
            coin: zero<SUI>(),
        };
        table_vec::push_back(&mut bottleList.list,redpacketbottle)
    }

    //创建有sui红包漂流瓶
    public fun createRedpacketBottle(
        coin: Coin<SUI>,
        bottleList:&mut RedpacketBottleList,
        message: String,
        ctx:&mut TxContext
    ){
        let balance = Coin::balance(&coin);
        let redpacketbottle = RedpacketBottle{
            id: object::new(ctx),
            message,
            coin: balance,
        };
        table_vec::push_back(&mut bottleList.list,redpacketbottle)
    }

    //抽取漂流瓶
    public fun getRedpacketBottle(
        redpacketbottleList:&mut RedpacketBottleList,
        random:& Random,
        ctx:&mut TxContext
    ){
        let length = table_vec::length(&mut redpacketbottleList.list);
        let mut generator = random::new_generator(random,ctx);
        let value = random::generate_u64_in_range(&mut generator,0,length);
        let element = table_vec::borrow_mut(&mut redpacketbottleList.list,value);
        transfer::public_transfer(element,ctx.sender());
    }

    //领取漂流瓶内红包
    public fun claimRedpacketBottle(
        bottleList:&mut RedpacketBottle,
        ctx:&mut TxContext
    ){
        assert!(bottleList.coin.value() != 0,0);
        transfer::public_transfer(bottleList.coin,ctx.sender());
    }
}