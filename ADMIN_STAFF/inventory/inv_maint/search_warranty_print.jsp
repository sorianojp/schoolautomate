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
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","search_warranty.jsp");
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
	int i = 0;
	boolean bolPageBreak = false;
	InventorySearch InvSearch = new InventorySearch();
	vRetResult = InvSearch.searchWarranty(dbOP,request);
	
	if (vRetResult != null && vRetResult.size() > 0){
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size())/(14*iMaxRecPerPage);	
	if((vRetResult.size() % (14*iMaxRecPerPage)) > 0) ++iTotalPages;
	for (;iNumRec < vRetResult.size();iPage++){
		
%>
<form name="form_">  
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<%
			if(WI.fillTextValue("optWarranty").equals("0")){
				strTemp = "WITH EXPIRED";
			}else if (WI.fillTextValue("optWarranty").equals("1")){
				strTemp = "WITH VALID";
			}else{
				strTemp = "WITHOUT";
			}
		%>
    <tr> 
      <td height="20" colspan="4" class="thinborder"><div align="center"> 
          <strong>ITEM <%=strTemp%> WARRANTY AS OF <%=WI.getTodaysDate(10)%></strong></div></td>
    </tr>
    
    <tr> 
      <td width="19%" height="28" align="center" class="thinborder"><font size="1"><strong>ITEM</strong></font></td>
      <td width="31%" align="center" class="thinborder"><strong><font size="1">OWNERSHIP</font></strong></td>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
      <td width="13%" align="center" class="thinborder"><strong><font size="1">WARRANTY DATE </font></strong> </td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=14,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>		
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+1),"")%><%=WI.getStrValue((String) vRetResult.elementAt(i+10),"(",")","")%><font size="1"><%=WI.getStrValue((String) vRetResult.elementAt(i+2),"<br>&nbsp;Code: ","","")%><%=WI.getStrValue((String) vRetResult.elementAt(i+11),"<br>&nbsp;Property #: ","","")%></font></td>
      <%if(vRetResult.elementAt(i+3) == null || ((String) vRetResult.elementAt(i+3)).equals("0")
					|| vRetResult.elementAt(i+4) == null || ((String) vRetResult.elementAt(i+4)).equals("0")){
					strTemp = "";
				}else{
					strTemp = " - ";
				}				
			%>			
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"",strTemp,"")%><%=WI.getStrValue((String) vRetResult.elementAt(i+4),"")%><%=WI.getStrValue((String) vRetResult.elementAt(i+5),"<br>","<br>","&nbsp;")%><%=WI.getStrValue((String) vRetResult.elementAt(i+6),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td>
    </tr>
    <%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18"  colspan="3" align="center">&nbsp;</td>
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