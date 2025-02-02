<%@ page language="java" import="utility.*, inventory.InventorySearch, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
	if(strSchCode.startsWith("VMA")){%>
	<jsp:forward page="inv_view_per_office_print_vma.jsp"></jsp:forward>
	<%return;}
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
	

	double dPageTotal  = 0d;
	double dGrandTotal = 0d;
	
		
	

	int iElemCount = 0;
	InventorySearch InvSearch = new InventorySearch();
	vRetResult = InvSearch.viewInventorybyOffice(dbOP,request);
	if(vRetResult != null && vRetResult.size() > 0)
		iElemCount = InvSearch.getElemCount();
	boolean bolPageBreak  = false;
	boolean bolLooped = false;
	
	if (vRetResult != null) {
	int i = 0; 
	int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"10"));
	String strCurCollege = null;
	String strCurDept = null;
	String strCollName = null;
	String strDeptName = null;
	String strTemp2 = null;

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
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="10" align="center"><strong>INVENTORY PER OFFICE</strong></td>
    </tr>
		<%if(WI.fillTextValue("status_name").length() > 0){%>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="10">&nbsp;<%=WI.fillTextValue("status_name")%></td>
    </tr>
		<%}%>
		<%
			if(iNumRec == 0){
				strCollName = (String)vRetResult.elementAt(12);
				strDeptName = (String)vRetResult.elementAt(13);
			}
		%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="10"><%=WI.getStrValue(strCollName,strDeptName)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">	
    <tr> 
      <td width="6%" height="18" align="center" class="thinborder"><font size="1"><strong>QUANTITY</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>LOCATION</strong></font></td>
      <td width="18%" align="center" class="thinborder"><font size="1"><strong>ITEM</strong></font></td>
			<%if(WI.fillTextValue("show_property").length() > 0){%>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">PROPERTY # </font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">DATE ACQUIRED </font></strong></td>
			<%}%>
			<td width="7%" align="center" class="thinborder"><strong><font size="1">UNIT PRICE </font></strong></td>
			<td width="6%" align="center" class="thinborder"><strong><font size="1">AMOUNT</font></strong></td>			
      <td width="7%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
	  <%if(WI.fillTextValue("show_remarks").length() > 0){%>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">REMARKS</font></strong></td>
	  <%}%>
	  <%if(WI.fillTextValue("show_code").length() > 0){%>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">CODE</font></strong></td>
	  <%}%>
    </tr>    
     <% bolLooped = false;		
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=iElemCount,++iIncr, ++iCount){
		i = iNumRec;		
		
		if (iCount > iMaxRecPerPage){
			strCollName = (String) vRetResult.elementAt(i+11);
			strDeptName = (String) vRetResult.elementAt(i+12);
			bolPageBreak = true;
			break;
		} else 
			bolPageBreak = false;			
			
			if(bolLooped){
				if(!strCurCollege.equals((String) vRetResult.elementAt(i)) ||
					 !strCurDept.equals((String) vRetResult.elementAt(i+1))){
					strCollName = (String) vRetResult.elementAt(i+11);
					strDeptName = (String) vRetResult.elementAt(i+12);
					bolPageBreak = true;
					break;
				}
			}
	  %>
    <tr> 
      <td align="right" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+4),"&nbsp;")%> <%=WI.getStrValue((String) vRetResult.elementAt(i+5),"&nbsp;")%>&nbsp;</td>
			<%strTemp = "";
				strTemp2 = "";
				strTemp = WI.getStrValue((String) vRetResult.elementAt(i+6),"Bldg : ","","");
				if(strTemp.length() > 0)
					strTemp2 = "<br>";
				strTemp += WI.getStrValue((String) vRetResult.elementAt(i+7),strTemp2 + "Rm # : ","","&nbsp;");
				
				strTemp2 = "";
				if(strTemp.length() > 0)
					strTemp2 = "<br>";
				strTemp += WI.getStrValue((String) vRetResult.elementAt(i+10),strTemp2 +"Loc. Desc : ","","");
				
			%>
      <td valign="top" class="thinborder">
			<%=strTemp%>&nbsp;</td>
      <td height="21" valign="top" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+8),"","<br>","")%><%=WI.getStrValue((String) vRetResult.elementAt(i+9)," - ","","&nbsp;")%></td>
			<%if(WI.fillTextValue("show_property").length() > 0){%>
      <td class="thinborder"><%=WI.getStrValue((String) vRetResult.elementAt(i+13),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String) vRetResult.elementAt(i+14),"&nbsp;")%></td>			
			<%}%>
			<%
				strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+15),true);
			%>
			<td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+16),true);
				
				if(vRetResult.elementAt(i+16) != null) {
					dPageTotal  += Double.parseDouble((String)vRetResult.elementAt(i+16));
					dGrandTotal += Double.parseDouble((String)vRetResult.elementAt(i+16));
				}
			%>			
			<td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				if(WI.fillTextValue("show_status").equals("1"))
					strTemp = (String) vRetResult.elementAt(i+17);
				else
					strTemp = "";
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	  <%if(WI.fillTextValue("show_remarks").length() > 0){%>
      <td class="thinborder">&nbsp;</td>
	  <%}%>
	  <%
		strTemp = (String) vRetResult.elementAt(i+18);
	  %>	  
	  <%if(WI.fillTextValue("show_code").length() > 0){%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
	  <%}%>
    </tr>
    <%
			bolLooped = true;
			strCurCollege = (String) vRetResult.elementAt(i);
			strCurDept = (String) vRetResult.elementAt(i+1);
		} // end for loop%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="19"  colspan="3">
		<%if(strSchCode.startsWith("WUP")){%>
	  		<strong>Page Total: <%=CommonUtil.formatFloat(dPageTotal, true)%></strong>
	  	<%dPageTotal = 0d;}else{%>
	  		&nbsp;
	  	<%}%>
	  </td>
    </tr>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>

<%if(strSchCode.startsWith("WUP")){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="19"  colspan="3">
	  		<strong>Grand Total: <%=CommonUtil.formatFloat(dGrandTotal, true)%></strong>
	  </td>
    </tr>
  </table>
<%}%>

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