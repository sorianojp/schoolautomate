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
<body bgcolor="#FFFFFFF">
<form name="form_" action="inv_view_inventory_print.jsp" method="post" >
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

	InventorySearch InvSearch = new InventorySearch();
	vRetResult = InvSearch.viewInventorybyOffice(dbOP,request);
	boolean bolPageBreak  = false;
	
	if (vRetResult != null) {
	int i = 0; 
	int k = 0; 
	int iCount = 0;
	int iInfinite = 0;
	String strCurCollege = null;
	String strDeptIndex = null;
	String strCOllName = null;

	int iNumRec = 0; //System.out.println(vRetResult);
	int iIncr    = 1;
	for (;iNumRec < vRetResult.size();){	
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#000000"> 
      <td height="25" colspan="5" bgcolor="#FFFFFF"><div align="center"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%></font></div></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="19" ><div align="right"></div></td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4"><div align="center"> <strong>INVENTORY LIST</strong> 
        </div></td>
    </tr>
    <%
	if(iCount == 0 && iNumRec == 0)
		strCOllName = (String)vRetResult.elementAt(12);	
	%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4"><%=WI.getStrValue(strCOllName,"&nbsp;")%></td>
    </tr>
    <tr> 
      <td width="8%" height="18"><div align="center"><font size="1"><strong>QUANTITY</strong></font></div></td>
      <td width="28%"><div align="center"><font size="1"><strong>ITEM</strong></font></div></td>
      <td width="19%"><div align="center"><strong><font size="1">STATUS</font></strong></div></td>
      <td width="22%"><div align="center"><strong><font size="1">REMARKS</font></strong></div></td>
    </tr>
    <tr> 
      <td height="16" colspan="4" class="thinborderBOTTOM"><hr size="1" color="black"></td>
    </tr>
    <% iIncr = 1;
	 for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=14,++iIncr, ++iCount){
		i = iNumRec;
		if(iCount == 1){
			strCurCollege = WI.getStrValue((String)vRetResult.elementAt(i),"0");
			strDeptIndex = WI.getStrValue((String)vRetResult.elementAt(i+1),"0");
			strCOllName= (String)vRetResult.elementAt(i+12);
		}
			
		if (iCount >40){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	
				
//		if((iCount > 1 && i + 12 < vRetResult.size() && (!((String)vRetResult.elementAt(i)).equals((String)vRetResult.elementAt(i+13))
//				  || !((String)vRetResult.elementAt(i+1)).equals((String)vRetResult.elementAt(i+14)) )) 
//		    || i + 13 > vRetResult.size()){
//			System.out.println("(String) 1  " + (String)vRetResult.elementAt(i));
//			System.out.println("(String) 13 " + (String)vRetResult.elementAt(i+13));
//			bolPageBreak = true;
//			break;			
//		}

		if(!(strCurCollege).equals((String)vRetResult.elementAt(i))) {
			strCurCollege = (String)vRetResult.elementAt(i);
			strDeptIndex = (String)vRetResult.elementAt(i+1);
			strCOllName = (String)vRetResult.elementAt(i+12);
			bolPageBreak = true;
			break;									
		}				
	%>
    <tr> 
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+4),"&nbsp;")%> <%=WI.getStrValue((String) vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td height="21" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+9),"&nbsp;")%><%=WI.getStrValue((String) vRetResult.elementAt(i+10)," - ","","&nbsp;")%></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="11" colspan="4"></td>
    </tr>
    <tr>
      <td height="11" colspan="4">Total Number of Items: <%=iIncr-1%> </td>
    </tr>
    <tr>
      <td height="11" colspan="4"></td>
    </tr>
    <tr>
      <td height="11" colspan="4"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="19"  colspan="3"><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="19"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
  
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