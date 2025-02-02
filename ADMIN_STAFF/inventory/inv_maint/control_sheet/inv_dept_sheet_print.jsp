<%@ page language="java" import="utility.*, inventory.InventorySearch, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" SRC="../../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","inv_dept_sheet.jsp");
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
	double dTemp = 0d;
	
	InventorySearch InvSearch = new InventorySearch();
	vRetResult = InvSearch.viewInvSheetPerDept(dbOP,request);
	boolean bolPageBreak  = false;
	boolean bolLooped = false;
	
	if (vRetResult != null) {
	int i = 0; 
	int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
	String strCurCollege = null;
	String strCurDept = null;
	String strCollName = null;
	String strDeptName = null;

	int iNumRec = 0; //System.out.println(vRetResult);
	int iIncr    = 1;
	for (;iNumRec < vRetResult.size();){
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF">
		<%
			if(iNumRec == 0){
				strCollName = (String)vRetResult.elementAt(5);
				strDeptName = (String)vRetResult.elementAt(6);
			}
		%>
    <tr> 
      <td height="20" colspan="3" align="center"><strong><font size="2">CONTROL SHEET PER OFFICE</font></strong><br>
      <strong>&nbsp;<%=WI.getStrValue(strCollName,strDeptName)%></strong></td>
    </tr>
    <tr> 
      <td height="21" colspan="3" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
    <tr>
      <td width="19%" align="center" class="thinborder"><strong><font size="1">ITEM CODE</font></strong></td>
      <td width="49%" height="22" align="center" class="thinborder"><font size="1"><strong>ITEM NAME </strong></font></td>
      <td width="32%" align="center" class="thinborderBOTTOMLEFTRIGHT"><strong><font size="1">AVAILABLE </font></strong></td>
    </tr>    
     <% bolLooped = false;		
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=9,++iIncr, ++iCount){
		i = iNumRec;
		
		if (iCount > iMaxRecPerPage){
			strCollName = (String) vRetResult.elementAt(i+5);
			strDeptName = (String) vRetResult.elementAt(i+6);
			bolPageBreak = true;
			break;
		} else 
			bolPageBreak = false;			
			
			if(bolLooped){
				if(!strCurCollege.equals((String) vRetResult.elementAt(i+7)) ||
					 !strCurDept.equals((String) vRetResult.elementAt(i+8))){
					strCollName = (String) vRetResult.elementAt(i+5);
					strDeptName = (String) vRetResult.elementAt(i+6);
					bolPageBreak = true;
					break;
				}
			}
	  %>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td> 
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"")%><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;(",")","")%></td>
      <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3),"")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"")%></td>
    </tr>
    <%
			bolLooped = true;
			strCurCollege = (String) vRetResult.elementAt(i+7);
			strCurDept = (String) vRetResult.elementAt(i+8);
		} // end for loop%>
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>		
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>