<%@ page language="java" import="utility.*,inventory.InventorySetting,java.util.Vector" %>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script> 
<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-InventorySetting"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}

	if(WI.fillTextValue("my_home").equals("1"))
		iAccessLevel = 2 ;
	
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
								"Admin/staff-PURCHASING-InventorySetting-InventorySetting Items","item_reorder_point.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.

	InventorySetting InvSetting = new InventorySetting();	
	Vector vRetResult = null; 
	int iDefault = 0;
	String strCategory = null;
	String strClass = null;
	String strItem = null;
	String strChecked = null;
	int iSearchResult = 0;
	int i = 0;
	boolean bolPageBreak  = false;
	 
	vRetResult = InvSetting.getBelowReorderPoint(dbOP,request);
 	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size())/(14*iMaxRecPerPage);	
	if((vRetResult.size() % (14*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
%>
<form name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	  <tr>
      	<td height="25" align="center"  colspan="5" class="thinborder"><strong>LIST OF  ITEMS BELOW REORDER POINT </strong></td>
	  </tr>    
    <tr>
      <td width="4%" align="center" class="thinborder">&nbsp;</td> 
      <td width="10%" align="center" class="thinborder">ITEM CODE  </td>
      <td width="14%" height="25" align="center" class="thinborder">AVAILABLE QTY</td>
      <td width="55%" align="center" class="thinborder">PARTICULARS/ITEM DESCRIPTION </td>
      <td width="17%" align="center" class="thinborder">Reorder point </td>
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
	  <td align="right" class="thinborder"><%=iIncr%>&nbsp;</td> 
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i+1)%>&nbsp;</td>
      <td height="25" align="right" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+12),"",(String)vRetResult.elementAt(i+3),"")%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i+2)%><%=WI.getStrValue((String)vRetResult.elementAt(i+5))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9), "","&nbsp;" +(String)vRetResult.elementAt(i+3),"")%></td>
	</tr>
	<%} // end for loop%>
     <tr> 
      <td class="thinborder" height="25" colspan="5">&nbsp;</td>
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