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
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./inv_borrow_view_list_print.jsp" />
<% return;}
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
		request.getSession(false).setAttribute("go_home","../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY MAINTENANCE","inv_borrow_view_list.jsp");
	
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
<body bgcolor="#D2AE72">
<form name="form_" action="inv_borrow_view_list.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - VIEW BORROWED ITEM(S) PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"><font size="3" color="red"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></font></td>
    </tr>
    <tr> 
      <td width="5%" height="30" align="center">&nbsp;</td>
      <td width="15%"><strong>Borrow Date</strong></td>
      <td valign="middle">From 
        <%strTemp = WI.fillTextValue("date_fr");%> <input name="date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("date_to");%> <input name="date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <%if (vRetResult != null && vRetResult.size()>0){%>
    <tr> 
      <td height="37" colspan="3"><div align="right"> <a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print the list </font> </div></td>
    </tr>
    <%}%>
  </table>
	<%if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="4" class="thinborder"><div align="center"> 
          <p><strong><font size="2">BORROW DETAILS</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td  height="25" colspan="2" class="thinborderBOTTOMLEFT" align="left"><font size="1">&nbsp;</font></td>
      <td colspan="2" align="right" class="thinborderBOTTOM"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/InvMaint.defSearchSize;
		if(iSearchResult % InvMaint.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%>
        <select name="jumpto" onChange="ReloadPage();" style="font-size:11px">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%	}
			}// end page printing
			%>
        </select> <%} else {%>
        &nbsp;
        <%} //if no pages %></td>
    </tr>
    <tr> 
      <td width="25%" height="25" class="thinborder" align="center"><font size="1"><strong><font size="1">BORROWER'S 
        DETAIL</font></strong></font></td>
      <td width="35%" class="thinborder" align="center"><font size="1"><strong>ITEM 
        DETAILS</strong></font></td>
      <td width="25%" class="thinborder" align="center"><strong><font size="1">RETURN 
        DETAIL (DATE/TIME) </font></strong></td>
      <%if(false){%>
      <td width="15%" align="center" class="thinborder">&nbsp; </td>
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
         <%=WI.getStrValue((String)vItems.elementAt(j),"Item Name : ","<br>","")%> 
		<%=WI.getStrValue((String)vItems.elementAt(j+3),"Property #: ","<br>","")%>
		<%=WI.getStrValue((String)vItems.elementAt(j+2),"Category : ","<br>","")%> 
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
      <td class="thinborder" align="left"> <%if (((String)vRetResult.elementAt(i+17)).equals("0")){%> <a href='javascript:EditThis("<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i+1)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%} else {%>
        returned
        <%}%> </td>
      <%}%>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<%if (vRetResult != null && vRetResult.size()>0){%>
    <tr>
      <td height="25"  colspan="3"><div align="center"> </div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
     	<input type="hidden" name="print_pg">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>