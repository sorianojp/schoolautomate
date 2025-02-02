<%@ page language="java" import="utility.*, inventory.InventorySearch, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function ReloadPage()
{
	document.form_.executeSearch.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","inv_view_inventory_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}

	Vector vRetResult = null;
	int iTemp = 0;
	String strTemp2 = null;
	String strTemp3 = null;
	String strQuery = "";
	
	String[] astrSortByName   = {"Status", "College", "Laboratory/Stock Room", "Non-Acad Office/Department", "Building"};
	String[] astrSortByVal    = {"inv_preload_status.INV_STATUS", "college.C_CODE", "E_ROOM_DETAIL.ROOM_NUMBER", "DEPARTMENT.D_NAME", "E_ROOM_BLDG.BLDG_NAME"};
	
	InventorySearch InvSearch = new InventorySearch();
	if (WI.fillTextValue("executeSearch").equals("1")){
		vRetResult = InvSearch.searchInventory(dbOP,request);
	}
%>
<body bgcolor="#FFFFFFF">
<form name="form_" action="inv_view_inventory_print.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#000000"> 
      <td height="25" colspan="5" bgcolor="#FFFFFF"><div align="center"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%></font></div></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="29">&nbsp;</td>
      <td width="4%" height="29">&nbsp;</td>
      <td width="4992%" height="29" colspan="4"><div align="right"></div></td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="5" class="thinborder"><div align="center"> 
          <p><strong><font size="2">INVENTORY LIST</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td width="8%" height="28" class="thinborder"><div align="center"><font size="1"><strong>QUANTITY</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>ITEM</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong><font size="1">STATUS</font></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><font size="1">DATE 
          STATUS UPDATED</font></strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong><font size="1">REMARKS</font></strong></div></td>
    </tr>
    <%if (vRetResult != null && vRetResult.size() > 0){
		for (int i = 0; i < vRetResult.size(); i+=10){
	%>
    <tr> 
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+1),"&nbsp;")%> <%=WI.getStrValue((String) vRetResult.elementAt(i+9),"&nbsp;")%></td>
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String) vRetResult.elementAt(i+6),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String) vRetResult.elementAt(i+8),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String) vRetResult.elementAt(i+7),"&nbsp;")%></td>
    </tr>
    <%}
	}
	%>
    <tr> 
      <td height="16" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="48"  colspan="3"><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_pg">
</form>
<script language="JavaScript">
window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>