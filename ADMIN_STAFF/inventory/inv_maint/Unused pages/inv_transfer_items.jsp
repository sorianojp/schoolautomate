<%@ page language="java" import="utility.*,inventory.InventoryMaintenance,java.util.Vector" %>
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
<script language="JavaScript">
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PageAction(strAction,strIndex,strDelItem){
	if(strAction == 0){
		var vProceed = confirm('Delete '+strDelItem+' ?');
		if(vProceed){
			document.form_.pageAction.value = strAction;
			document.form_.strIndex.value = strIndex;
			document.form_.printPage.value = "";
			this.SubmitOnce('form_');
		}		
	}
	else{
		document.form_.pageAction.value = strAction;
		document.form_.strIndex.value = strIndex;
		document.form_.printPage.value = "";
		this.SubmitOnce('form_');
	}	
}
function CancelRecord(){
    document.form_.cancelClicked.value = "1";
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = "";
	document.form_.strIndex.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}

function PageLoad(){
 	document.form_.trans_no.focus();
}
function SearchProperty(strRoomNo){
	var pgLoc = "search_property.jsp?opner_info=form_.prop_no&room_idx="+strRoomNo;
	var win=window.open(pgLoc,"SearchProperty",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-Transfer"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
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
								"Admin/staff-PURCHASING-Transfer-Transfer Items","inv_transfer_items.jsp");
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

	InventoryMaintenance InvMaint = new InventoryMaintenance();	
	Vector vTransferInfo = null;
	Vector vRetResult = null;
	Vector vTransferItems = null;

	if(WI.fillTextValue("trans_no").length() > 0){
		vTransferInfo = InvMaint.operateOnTransferInfo(dbOP, request, 3);
	//	System.out.println("vTransferInfo " + vTransferInfo);
		if (vTransferInfo == null || vTransferInfo.size() == 0){
			strErrMsg = "Naay Error ";
		}
	}
	
			
%>
<form name="form_" method="post" action="./inv_transfer_items.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
      <%if(WI.fillTextValue("is_supply").equals("0")){%>
	  <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          INVENTORY : ENCODE NON-SUPPLIES/EQUIPMENT TRANSFER PAGE ::::</strong></font></div></td>
	   </tr>	  
	  <%}else{%>
	  <tr bgcolor="#A49A6A">	  
	  <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          INVENTORY : ENCODE SUPPLIES TRANSFER PAGE ::::</strong></font></div></td>
	  </tr>
	  <%}%>    
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="21%">Transfer No.</td>
      <td width="76%"><strong> 
        <input type="text" name="trans_no" class="textbox" value="<%=WI.fillTextValue("trans_no")%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong>&nbsp;		
		<img src="../../../images/search.gif" border="0">
		<a href="javascript:ProceedClicked();"> 
        <img src="../../../images/form_proceed.gif" border="0">
        </a>
		</td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <% if(vTransferInfo != null && vTransferInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>SOURCE STOCK ROOM/ LABORATORY</strong></div></td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="22%">Transfer No. :</td>
      <td width="25%"><strong>&nbsp; 
        <% if(vTransferInfo != null && vTransferInfo.size() > 0){
	  		strTemp = (String)vTransferInfo.elementAt(1);
	  	}	  
	  %>
        <%=strTemp%> </strong></td>
      <td width="21%">Requested By :</td>
      <td width="29%">&nbsp; <strong> 
        <% if(vTransferInfo != null && vTransferInfo.size() > 0){
	  		strTemp = (String)vTransferInfo.elementAt(12);
	  	}	  
	  %>
        <%=strTemp%> </strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Non-Acad. Office/Dept :</td>
      <td><strong>&nbsp; 
        <% if(vTransferInfo != null && vTransferInfo.size() > 0){
	  		strTemp = (String)vTransferInfo.elementAt(13);
	  	}	  
	  %>
        <%=WI.getStrValue(strTemp,"&nbsp;")%> </strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>College/Dept :</td>
      <td colspan="2"><strong>&nbsp; 
        <% if(vTransferInfo != null && vTransferInfo.size() > 0){
	  		strTemp = (String)vTransferInfo.elementAt(15);
	  	}	  
	  %>
        <%=WI.getStrValue(strTemp,"&nbsp;")%> </strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Room Number : </td>
      <td colspan="2"><strong>&nbsp; 
        <% if(vTransferInfo != null && vTransferInfo.size() > 0){
	  		strTemp = (String)vTransferInfo.elementAt(17);
	  	}	  
	  %>
        <%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="3"><hr size="1"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Property Number : </td>
      <td width="75%" valign="bottom"><strong> 
        <%
		  strTemp = WI.fillTextValue("prop_no");
	  %>
        <input type="text" name="prop_no" class="textbox" value="<%=WI.getStrValue(strTemp,"")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <strong><font size="1"> <a href="javascript:SearchProperty(<%=(String)vTransferInfo.elementAt(8)%>);"><img src="../../../images/search.gif" alt="search" border="0"></a> 
        <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" alt="search" width="71" height="23" border="0"></a> 
        </font></strong> </strong> </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="22%" valign="bottom">Quantity :</td>
      <td valign="bottom"> 
        <input name="qty" type="text" size="5" class="textbox" value="<%=strTemp%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="AllowOnlyIntegerExtn('form_','qty','.')"></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td> <a href="javascript:PageAction(1,0,'');"> <img src="../../../images/add.gif" border="0"></a> 
        <font size="1" >click to save entry</font> <a href="javascript:PageAction(2,<%=WI.fillTextValue("strIndex")%>,'');"><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">click to save changes</font> <a href="javascript:CancelRecord();"> 
        <img src="../../../images/cancel.gif" border="0"></a> <font size="1">click 
        to cancel edit</font> </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
      <td height="29"><div align="right"> </div></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	  <tr>
      	  <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT">
		  <div align="center"><font color="#FFFFFF"><strong>LIST OF REQUESTED ITEMS</strong></font></div>
		  </td>
	  </tr>
	  <tr>
	  	  <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT">
		  <div align="center"><font color="#FFFFFF"><strong>LIST OF REQUESTED SUPPLIES</strong></font></div>
		  </td>
	  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td height="25" colspan="7" class="thinborder">Requested by : </td>
    </tr>
    <tr> 
      <td width="5%" height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>QUANTITY</strong></div></td>
      <td width="4%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="4%" class="thinborder"><div align="center"><strong>ITEM</strong></div></td>
      <td width="21%" class="thinborder"><div align="center"><strong>PARTICULARS/ITEM 
          DESCRIPTION </strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>EDIT</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>DELETE</strong></div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"></div></td>
      <td class="thinborder"><div align="center"></div></td>
      <td class="thinborder"><div align="left"></div></td>
      <td class="thinborder"><div align="left"></div></td>
      <td class="thinborder"><div align="left"></div></td>
      <td class="thinborder">
        <img src="../../../images/edit.gif" border="0"> </td>
      <td class="thinborder"> 
        <img src="../../../images/delete.gif" border="0"> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">   
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="cancelClicked" value="">
  <input type="hidden" name="strIndex" value="<%=WI.fillTextValue("strIndex")%>">
  <input type="hidden" name="printPage" value=""> 
  </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
