<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
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
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function EditThis(strIndex, strBorrow)
{
	location = "./inv_borrow.jsp?info_index="+strIndex+"&borrow_no="+strBorrow+"&prepareToEdit=1";
}
function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}
</script>
</head>
<%
	//authenticate user access level	
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
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY MAINTENANCE","inv_borrow_view_list_print.jsp");
	
	Vector vRetResult = null;
	int i = 0;
	int iTemp = 0;
	String strErrMsg = null;
	String strTemp = null;
	Vector vItems = null;

	int iSearchResult = 0;
	
	InventoryMaintenance InvMaint = new InventoryMaintenance();

	vRetResult = InvMaint.operateOnBorrowedList(dbOP, request);
	if (vRetResult != null)
		iSearchResult = InvMaint.getSearchCount();
	else if (vRetResult == null && WI.fillTextValue("date_fr").length()>0)
		strErrMsg = InvMaint.getErrMsg();
%>
<body bgcolor="#FFFFFF">
<form name="form_" action="inv_borrow_view_list_print.jsp" method="post" >
  <%if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3" class="thinborder"><div align="center"> 
          <p><strong><font size="2">BORROW DETAILS</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td width="25%" height="25" class="thinborder" align="center"><font size="1"><strong><font size="1">BORROWER'S 
        DETAIL</font></strong></font></td>
      <td width="35%" class="thinborder" align="center"><font size="1"><strong>ITEM 
        DETAILS</strong></font></td>
      <td width="25%" class="thinborder" align="center"><strong><font size="1">RETURN 
        DETAIL (DATE/TIME) </font></strong></td>
      <%if(false){%>
      <%}%>
    </tr>
    <%for (i =0; i<vRetResult.size(); i+=13){
 	vItems = (Vector)vRetResult.elementAt(i+12);
 %>
    <tr> 
      <td class="thinborder" height="25"><font size="1">&nbsp; <strong>ID number: 
        </strong><%=(String)vRetResult.elementAt(i+5)%><br>
        <strong>Name: </strong><br>
        <%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%><br>
        <strong>Borrow Date: </strong><%=(String)vRetResult.elementAt(i+11)%> </font></td>
      <td class="thinborder"><font size="1"> 
        <%for(int j = 0;j < vItems.size(); j+=4){%>
        <%=WI.getStrValue((String)vItems.elementAt(j),"Item Name : ","<br>","")%> <%=WI.getStrValue((String)vItems.elementAt(j+3),"Property #: ","<br>","")%> <%=WI.getStrValue((String)vItems.elementAt(j+2),"Category : ","<br>","")%> 
        <%}// end inner for loop%>
        <br>
        </font></td>
      <td class="thinborder"><font size="1"> <strong>Return date: </strong><%=WI.getStrValue((String)vRetResult.elementAt(i+9),"Undefined")%><br>
        <strong>Return time: </strong> 
        <%if (vRetResult.elementAt(i+10) != null){
      iTemp = Integer.parseInt((String)vRetResult.elementAt(i+10));
      if (iTemp <= 12){%>
        <%=iTemp%> 
        <%} else{%>
        <%=(iTemp-12)%> 
        <%}
      if (iTemp <12){%>
        AM 
        <%} else {%>
        PM 
        <%}} else {%>
        Undefined 
        <%}%>
        </font></td>
      <%if(false){%>
      <%}%>
    </tr>
    <%}%>
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