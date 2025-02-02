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
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","view_csr_inventory.jsp");
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

	InventorySearch InvSearch = new InventorySearch();
	vRetResult = InvSearch.viewSuppliesPerOffice(dbOP,request);	
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
<form name="form_" >  
	<table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF">
    <%if(bolPageBreak || iNumRec == 0){%>
		<tr> 
      <td height="20" colspan="5"><div align="center"> 
          <strong><font size="2">SUPPLIES PER OFFICE </font></strong>
        </div></td>
    </tr>
		<%}%>
		<%
			if(iNumRec == 0){
				strCollName = (String)vRetResult.elementAt(16);
				strDeptName = (String)vRetResult.elementAt(17);
			}
		%>		
    <tr>
      <td height="20" colspan="6">&nbsp;<strong><%=WI.getStrValue(strCollName,strDeptName)%></strong></td>
    </tr>
	</table>
	<table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    
    <tr>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>ITEM CODE </strong></font></td> 
      <td width="38%" align="center" class="thinborder"><font size="1"><strong>ITEM</strong></font></td>
      <!--
			<td width="13%" align="center" class="thinborder"><font size="1"><strong>STOCK IN </strong></font></td>
			-->
      <td width="12%" height="28" align="center" class="thinborder"><font size="1"><strong>QUANTITY ON HAND </strong></font></td>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">UNIT PRICE</font></strong></td>
      <td width="12%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
    </tr>   
     <% bolLooped = false;		
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=18,++iIncr, ++iCount){
		i = iNumRec;		
		
		if (iCount > iMaxRecPerPage){
			strCollName = (String) vRetResult.elementAt(i+16);
			strDeptName = (String) vRetResult.elementAt(i+17);
			bolPageBreak = true;
			break;
		} else 
			bolPageBreak = false;						
			if(bolLooped){
				if(!strCurCollege.equals((String) vRetResult.elementAt(i+14)) ||
					 !WI.getStrValue(strCurDept).equals(WI.getStrValue((String) vRetResult.elementAt(i+15)))){
					strCollName = (String) vRetResult.elementAt(i+16);
					strDeptName = (String) vRetResult.elementAt(i+17);
					//bolPageBreak = true;
					break;
				}
			}
			
	  %>		
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+6),"&nbsp;")%></td> 
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+5),"","&nbsp;","")%><%=WI.getStrValue((String) vRetResult.elementAt(i+2),"&nbsp;")%><%=WI.getStrValue((String) vRetResult.elementAt(i+3),"(", ")","")%></td>
			<!--
      <td align="right" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+1),"&nbsp;")%> <%=WI.getStrValue((String) vRetResult.elementAt(i+4),"&nbsp;")%>&nbsp;</td>
			-->
      <td align="right" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+12),"&nbsp;")%> <%=WI.getStrValue((String) vRetResult.elementAt(i+4),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String) vRetResult.elementAt(i+11),true)%>&nbsp;</td>
      <td align="right" class="thinborder"><%=WI.getStrValue((String) vRetResult.elementAt(i+13),"&nbsp;")%>&nbsp;</td>
    </tr>
    <%
			bolLooped = true;
			strCurCollege = (String) vRetResult.elementAt(i+14);
			strCurDept = (String) vRetResult.elementAt(i+15);
		} // inner for loop%>
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