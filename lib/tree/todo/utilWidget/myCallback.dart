
//***************typedef is function-type alias, helps to define pointers to executable code within memory****************
// https://www.tutorialspoint.com/dart_programming/dart_programming_data_types.htm*/

// void => void
typedef void MCvoidVoid();

// void => dynamic 
typedef dynamic MCvoidDynamic();

// dynamic => void 
typedef void MCDynamicVoid(param1);

// dynamic => dynamic
typedef dynamic MCdynamicDynamic(param1);

// dynamic dynamic => void 
typedef void MC2Dynamicvoid(param1,param2);

// dynamic dynamic => dynamic
typedef dynamic MC2DynamicDynamic(param1,param2);

// dynamic dynamic dynamic => void
typedef void MC3Dynamicvoid(param1,param2,param3);

// dynamic dynamic dynamic => dynamic
typedef dynamic MC3DynamicDynamic(param1,param2,param3);