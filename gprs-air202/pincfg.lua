require"pins"
module(...,package.seeall)

--[[
��Ҫ����!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ʹ��ĳЩGPIOʱ�������ڽű���д�����GPIO�����ĵ�ѹ�����õ�ѹ�������ȼ�����ЩGPIO������������
������GPIOʹ��ǰ(�����ļ���pins.regǰ)����pmd.ldoset(��ѹ�ȼ�,��ѹ������)
��ѹ�ȼ����Ӧ�ĵ�ѹ���£�
0--------�ر�
1--------1.8V
2--------1.9V
3--------2.0V
4--------2.6V
5--------2.8V
6--------3.0V
7--------3.3V
IO����Ϊ���ʱ���ߵ�ƽʱ�������ѹ��Ϊ���õĵ�ѹ�ȼ���Ӧ�ĵ�ѹ
IO����Ϊ��������ж�ʱ����������ĸߵ�ƽ��ѹ���������õĵ�ѹ�ȼ��ĵ�ѹƥ��

��ѹ������Ƶ�GPIO�Ķ�Ӧ��ϵ���£�
pmd.LDO_VMMC��GPIO8��GPIO9��GPIO10��GPIO11��GPIO12��GPIO13
pmd.LDO_VLCD��GPIO14��GPIO15��GPIO16��GPIO17��GPIO18
pmd.LDO_VCAM��GPIO19��GPIO20��GPIO21��GPIO22��GPIO23��GPIO24
һ��������ĳһ����ѹ��ĵ�ѹ�ȼ����ܸõ�ѹ����Ƶ�����GPIO�ĸߵ�ƽ�������õĵ�ѹ�ȼ�һ��

���磺GPIO8�����ƽʱ��Ҫ�����2.8V�������pmd.ldoset(5,pmd.LDO_VMMC)
]]

--���������˿�Դģ�������п�����GPIO�����ţ�ÿ������ֻ����ʾ��Ҫ
--�û�����������Լ������������޸�
--ģ�������GPIO��֧���ж�

--pinֵ�������£�
--pio.P0_XX����ʾGPIOXX���ɱ�ʾGPIO 0 �� GPIO 31������pio.P0_15����ʾGPIO15
--pio.P1_XX����ʾGPIO(XX+32)���ɱ�ʾGPIO 32���ϵ�GPIO������pio.P1_2����ʾGPIO34

--dirֵ�������£�Ĭ��ֵΪpio.OUTPUT����
--pio.OUTPUT����ʾ�������ʼ��������͵�ƽ
--pio.OUTPUT1����ʾ�������ʼ��������ߵ�ƽ
--pio.INPUT����ʾ���룬��Ҫ��ѯ����ĵ�ƽ״̬
--pio.INT����ʾ�жϣ���ƽ״̬�����仯ʱ���ϱ���Ϣ�����뱾ģ���intmsg����

--validֵ�������£�Ĭ��ֵΪ1����
--valid��ֵ��pins.lua�е�set��get�ӿ����ʹ��
--dirΪ���ʱ�����pins.set�ӿ�ʹ�ã�pins.set�ĵ�һ���������Ϊtrue��������validֵ��ʾ�ĵ�ƽ��0��ʾ�͵�ƽ��1��ʾ�ߵ�ƽ
--dirΪ������ж�ʱ�����get�ӿ�ʹ�ã�������ŵĵ�ƽ��valid��ֵһ�£�get�ӿڷ���true�����򷵻�false
--dirΪ�ж�ʱ��cbΪ�ж����ŵĻص����������жϲ���ʱ�����������cb�������cb����������жϵĵ�ƽ��valid��ֵ��ͬ����cb(true)������cb(false)



--�������ú����PIN8����
PIN6 = {pin=pio.P0_3}
PIN7 = {pin=pio.P0_2}


--����GPIO8��GPIO9��GPIO10��GPIO11��GPIO12��GPIO13�ĸߵ�ƽ��ѹΪ2.8V
pmd.ldoset(5,pmd.LDO_VMMC)
pins.reg(PIN6,PIN7)