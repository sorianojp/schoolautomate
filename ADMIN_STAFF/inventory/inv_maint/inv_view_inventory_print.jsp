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
<style type="text/css">
    table.TOPRIGHT {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }

		TD.BOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }		
    TD.NoBorder {
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
		}
</style>
</head>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
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
<body onLoad="javascript:window.print();">
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
	boolean bolPageBreak = false;

	InventorySearch InvSearch = new InventorySearch();
		if(WI.fillTextValue("inventory_type").equals("0"))
			vRetResult = InvSearch.searchInventory(dbOP,request);
		else
			vRetResult = InvSearch.searchCompInventory(dbOP,request);

	if (vRetResult != null) {	
		int iPage = 1; int iCount = 0;
		int i = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
	
		int iNumRec = 0;//System.out.println(vRetResult);
		int iTotalPages = (vRetResult.size())/(17*iMaxRecPerPage);	
		if((vRetResult.size() % (17*iMaxRecPerPage)) > 0) ++iTotalPages;
		 for (;iNumRec < vRetResult.size();iPage++){
%>
<form name="form_" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#000000"> 
      <td height="25" colspan="5" bgcolor="#FFFFFF"><div align="center"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%></font></div></div></td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  
  <tr>
    <td align="right">Page <%=iPage%> of <%=iTotalPages%></td>
  </tr>
</table>

  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="TOPRIGHT">
    <tr> 
  		<td width="7%" height="28" align="center" class="BOTTOMLEFT"><font size="1"><strong>QUANTITY</strong></font></td>
      <td width="14%" align="center" class="BOTTOMLEFT"><font size="1"><strong>ITEM</strong></font></td>
			<%if(WI.fillTextValue("show_property").length() > 0){%>
      <td width="8%" align="center" class="BOTTOMLEFT"><span class="thinborderBOTTOM"><strong><font size="1">PROPERTY # </font></strong></span></td>
      <td width="8%" align="center" class="BOTTOMLEFT"><span class="thinborderBOTTOM"><strong><font size="1">DATE ACQUIRED </font></strong></span></td>
			<%}%>
      <td width="15%" align="center" class="BOTTOMLEFT"><font size="1"><strong>LABORATORY/STOCK 
        ROOM/LOC DESC. </strong></font></td>
			<% if(WI.fillTextValue("show_owner").equals("1")){ %>					
      <td width="12%" align="center" class="BOTTOMLEFT"><strong><font size="1">COLLEGE/ NON-ACAD OFFICE/DEPT.</font></strong></td>
			<%}%>
			<td width="6%" align="center" class="BOTTOMLEFT"><span class="thinborderBOTTOM"><strong><font size="1">UNIT PRICE </font></strong></span></td>
			<td width="6%" align="center" class="BOTTOMLEFT"><strong><font size="1">AMOUNT</font></strong></td>

      <td width="6%" align="center" class="BOTTOMLEFT"><strong><font size="1">STATUS</font></strong></td>
			<% if(WI.fillTextValue("show_update").equals("1")){ %>
      <td width="7%" align="center" class="BOTTOMLEFT"><strong><font size="1">DATE 
        STATUS UPDATED</font></strong></td>
			<%}%>
      <td width="15%" align="center" class="BOTTOMLEFT"><strong><font size="1">REMARKS</font></strong></td>
			<% if(WI.fillTextValue("show_code").equals("1")){ %>
      <td width="8%" align="center" class="BOTTOMLEFT"><strong><font size="1">ITEM CODE </font></strong></td>
			<%}%>
    </tr>
    <%
		for(iCount = 1;iNumRec < vRetResult.size(); iNumRec += 17, ++iCount){
		i = iNumRec;
		
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			

	%>
    <tr> 
      <td height="25" class="BOTTOMLEFT">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+1),"&nbsp;")%> <%=WI.getStrValue((String) vRetResult.elementAt(i+9),"&nbsp;")%></td>
			<%
				strTemp = (String) vRetResult.elementAt(i);
				strTemp += WI.getStrValue((String) vRetResult.elementAt(i+12),"<br> - ","","");
			%>
      <td class="BOTTOMLEFT">&nbsp;<%=strTemp%></td>
      <%if(WI.fillTextValue("show_property").length() > 0){%>
			<td class="BOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+13),"&nbsp;")%></td>
      <td class="BOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+14),"&nbsp;")%></td>
			<%}%>
      <td class="BOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+4),"","","")%>
														 <%=WI.getStrValue((String) vRetResult.elementAt(i+5),"<br>","&nbsp;","")%>
														 <%=WI.getStrValue((String) vRetResult.elementAt(i+10),"<br>","&nbsp;","&nbsp;")%></td>
			<%
				if(vRetResult.elementAt(i+2) == null || vRetResult.elementAt(i+3) == null){
					strTemp = "";
				}else{
					strTemp = " - ";
				}
			%>									
			<% if(WI.fillTextValue("show_owner").equals("1")){ %>										 
      <td class="BOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+2),"&nbsp;")%><%=strTemp%><%=WI.getStrValue((String) vRetResult.elementAt(i+3),"&nbsp;")%></td>
			<%}%>
			<%
				strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+15),true);
			%>			
			<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+16),true);
			%>			
			<td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				if(WI.fillTextValue("show_status").equals("1"))
					strTemp = (String) vRetResult.elementAt(i+6);
				else
					strTemp = "";
			%>			
      <td class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<% if(WI.fillTextValue("show_update").equals("1")){ %>
      <td class="BOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+8),"&nbsp;")%></td>
			<%}%>
			<%if(WI.fillTextValue("show_remarks").length() > 0)
					strTemp = (String) vRetResult.elementAt(i+7);
				else
					strTemp = "";
				
			%>
			
      <td class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<% if(WI.fillTextValue("show_code").equals("1")){ %>
      <td class="BOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+11),"&nbsp;")%></td>
			<%}%>
    </tr>
    <%}
	%>
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