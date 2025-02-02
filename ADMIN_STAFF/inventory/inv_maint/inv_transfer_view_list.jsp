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
	document.form_.print_pg.value="";
	this.SubmitOnce('form_');
}
function EditThis(strIndex, strTransfer, strItem)
{
	location = "./inv_transfer.jsp?info_index="+strIndex+"&trans_no="+strTransfer+"&prop_no="+strItem+"&prepareToEdit=1";
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}

</script>
</head>
<%
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./inv_transfer_view_list_print.jsp" />
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
								"INVENTORY-INVENTORY MAINTENANCE","inv_transfer_view_list.jsp");
	
	Vector vRetResult = null;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
	
	InventoryMaintenance InvMaint = new InventoryMaintenance();

	vRetResult = InvMaint.operateOnTransItemList(dbOP, request);
	if (vRetResult != null)
		iSearchResult = InvMaint.getSearchCount();
	else if (vRetResult == null && WI.fillTextValue("date_fr").length()>0)
		strErrMsg = InvMaint.getErrMsg();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="inv_transfer_view_list.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - VIEW TRANSFERED ITEM(S) PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"><font size="3" color="red"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></font></td>
    </tr>
    <tr> 
      <td width="5%" height="30" align="center">&nbsp;</td>
      <td width="15%"><strong>Transfer Date</strong></td>
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
        <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a> 
      </td>
    </tr>
    <%if (vRetResult != null && vRetResult.size()>0){%>
    <tr> 
      <td height="37" colspan="3">	  
	  <div align="right"> <a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print the list</font> </div>	  
		  </td>
    </tr>
    <%}%>
  </table>
	<%if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="7" class="thinborder"><div align="center"> 
          <p><strong><font size="2">TRANSFER DETAILS</font></strong></p>
        </div></td>
    </tr>
    <td  height="25" colspan="3" class="thinborderBOTTOMLEFT" align="left"><font size="1"><strong>TOTAL 
      ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
    <td colspan="4" align="right" class="thinborderBOTTOM"><%
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
      <td width="8%" height="25" class="thinborder"><div align="center"><font size="1"><strong>PROPERTY 
          # </strong></font></div></td>
      <td width="21%" class="thinborder"><div align="center"><font size="1"><strong>ITEM 
          CATEGORY/NAME/SERIAL #/PRODUCT #</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>QTY 
          TRANSFERED </strong></font></div></td>
      <td width="21%" class="thinborder"><div align="center"><font size="1"><strong>ORIGINAL 
      LOCATION </strong></font></div></td>
      <td width="21%" class="thinborder"><div align="center"><font size="1"><strong>TRANSFER 
      LOCATION </strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>TRANSFER 
      DATE</strong></font></div></td>
      <%if(false){%>
      <td width="7%" align="center" class="thinborder"> <div align="left"><font size="1"><strong>&nbsp;</strong></font></div>
        <div align="center"></div></td>
      <%}%>
    </tr>
    <%for (i = 0; i<vRetResult.size(); i+=16){%>
    <tr> 
      <td class="thinborder" height="25"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"> Item Name: <%=(String)vRetResult.elementAt(i+3)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"<br>Product No: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"<br>Serial No: ","","")%></font> </td>
      <td class="thinborder" align="center"> <font size="1"><%=(String)vRetResult.elementAt(i+6)%></font></td>
      <td class="thinborder"><font size="1"> <%=WI.getStrValue((String)vRetResult.elementAt(i+12),"College : ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+11),"<br>Department: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+7),"<br>Room: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+8),"<br>Location: ","","")%> </font></td>
      <td class="thinborder"> <font size="1"> <%=WI.getStrValue((String)vRetResult.elementAt(i+14),"College : ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+13),"<br>Department: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+9),"Room: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+10),"<br>Location: ","","")%> </font> </td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+15),"")%></font></td>
      <%if(false){%>
      <td class="thinborder"> <a href='javascript:EditThis("<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i+1)%>","<%=(String)vRetResult.elementAt(i+2)%>");'> 
        <img src="../../../images/edit.gif"  border="0"></a></td>
      <%}%>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<%if (vRetResult != null && vRetResult.size()>0){%>
    <tr>
      <td height="25"  colspan="3"><div align="center"></div></td>
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