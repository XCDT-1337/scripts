echo "DOMAIN ... "
echo ""
wmic computersystem get domain
wmic ntdomain
echo ""

echo "USERS ..."
echo ""
wmic useraccount 
echo ""

echo "STARTUP PROGRAMS ..."
echo ""
wmic startup
echo ""

echo "RUNNING PROCESSES..."
echo ""
tasklist
echo ""

echo "INSTALLED SOFTWARE ... "
echo ""
wmic product get Caption, InstallDate, Vendor
echo ""