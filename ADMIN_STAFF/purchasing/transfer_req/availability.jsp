<%@ page language="java" import="utility.*,inventory.InventoryMaintenance,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

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
	} else {
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
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function PageLoad(){
 	document.form_.req_no.focus();
}
function OpenSearch(){
	document.form_.printPage.value = "";
	var pgLoc = "request_view_search.jsp?opner_info=form_.req_no"+
							"&my_home="+document.form_.my_home.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function ReloadPage(){
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}


</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%
    if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="req_item_print_auf.jsp"/>
	<%return;}

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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
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
								"Admin/staff-PURCHASING-REQUISITION-Requisition Items","availability.jsp");
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
 	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vRetResult = null;
	boolean bolIsErr = false;
	boolean bolAllowEdit = false;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};
	String[] astrReqType = {"New","Replacement"};

	vReqInfo = InvMaint.operateOnTransferReqInfo(dbOP,request,3);
	if(vReqInfo == null && WI.fillTextValue("req_no").length() > 0)
		strErrMsg = InvMaint.getErrMsg();
	if(WI.fillTextValue("req_no").length() < 1)
		strErrMsg = "Input Requisition No.";


	if(WI.fillTextValue("pageAction").length() > 0){

		if(InvMaint.operateOnItemAvailability(dbOP, request) == false){
			strErrMsg = InvMaint.getErrMsg();
 		} else{
			if(!WI.fillTextValue("pageAction").equals("3")){
				strErrMsg = "Operation Successful.";
				vRetResult = null;
			}
		}
	}
	vReqItems = InvMaint.getRequestedItems(dbOP, request,true);
%>
<form name="form_" method="post" action="./availability.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr bgcolor="#A49A6A">
      <td height="25" align="center"><font color="#FFFFFF"><strong>::::
      REQUISITION : VIEW ITEM AVAILABILITY PAGE ::::</strong></font></td>
    </tr>

    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="21%">Requisition No.</td>
      <td width="76%"><strong>
        <input type="text" name="req_no" class="textbox" value="<%=WI.fillTextValue("req_no")%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong>&nbsp;
		<a href="javascript:OpenSearch();">
		<img src="../../../images/search.gif" border="0"></a>
		<a href="javascript:ProceedClicked();">
        <img src="../../../images/form_proceed.gif" border="0">
        </a>
	  </td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D">
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4" align="center"><strong>REQUISITION DETAILS </strong></td>
    </tr>
		<%//if(((String)vReqInfo.elementAt(1)).equals("0")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"><strong>ITEM SOURCE</strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Non-Acad. Office/Dept :</td>
      <td colspan="3"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
    </tr>
		<input type="hidden" name="d_index_fr" value="<%=(String)vReqInfo.elementAt(2)%>">
		<%//}else{%>
    <!--
		<tr>
      <td height="25">&nbsp;</td>
      <td>College/Dept :</td>
      <td colspan="3"><strong><%=(String)vReqInfo.elementAt(3)+"/"+WI.getStrValue((String)vReqInfo.elementAt(4),"All")%></strong></td>
    </tr>
		-->
		<%//}%>
    <tr>
      <td height="15" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="25%"><strong><%=WI.fillTextValue("req_no")%></strong></td>
      <td width="21%">Requested By :</td>
      <td width="29%"> <strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(13))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(12)%></strong></td>
    </tr>
	<%if(((String)vReqInfo.elementAt(5)).equals("0")){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)+"/"+WI.getStrValue((String)vReqInfo.elementAt(8),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
	<%}%>
  </table>
  <%if(vReqItems != null && vReqItems.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td align="right"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a> <font size="1">click to print Requisition Form</font></td>
  </tr>
</table>

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
 	  <tr>
      <td width="100%" height="25" align="center" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT">
		    <font color="#FFFFFF"><strong>LIST OF REQUESTED ITEMS</strong></font></td>
	  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr>
      <td height="25" colspan="5" class="thinborder">Requested by :<strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
    </tr>
    <tr>
      <td width="9%" height="29" align="center" class="thinborder"><strong>QUANTITY</strong></td>
      <td width="49%" align="center" class="thinborder"><strong>ITEM</strong></td>
      <td width="16%" align="center" class="thinborder"><strong>AVAILABLE</strong></td>
      <!--
			<td width="16%" align="center" class="thinborder"><strong>OPTION</strong></td>
			-->
      <td width="26%" align="center" class="thinborder"><strong>REMARKS</strong></td>
    </tr>
    <% int iCountItem = 0;
		//System.out.println("vReqItems " + vReqItems);
	for(int iLoop = 0;iLoop < vReqItems.size();iLoop+=8,iCountItem++){%>
	<tr>
			<input type="hidden" name="item_req_index_<%=iCountItem%>" value="<%=vReqItems.elementAt(iLoop)%>">
      <td height="25" align="right" class="thinborder"><%=vReqItems.elementAt(iLoop+1)%>&nbsp;<%=vReqItems.elementAt(iLoop+2)%>&nbsp;</td>
      <td class="thinborder"><%=vReqItems.elementAt(iLoop+3)%><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+4),"-","","")%></td>
			<%
			strTemp = (String) vReqItems.elementAt(iLoop+7);
			%>
			<td align="right" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"",(String)vReqItems.elementAt(iLoop+2),"No Stock")%>&nbsp;</td>
			<!--
			<%
 				//if(Double.parseDouble(WI.getStrValue(strTemp,"0")) > 0)
				//	strTemp = "0";
				//else
				//	strTemp = "1";
			%>
      <td class="thinborder">
			<select name="in_stock_<%//=iCountItem%>">
        <option value="1">Not Available</option>
        <%//if(strTemp.equals("0")){%>
        <option value="0" selected>Available</option>
        <%//}else{%>
        <option value="0">Available</option>
        <%//}%>
      </select></td>
			-->
			<%
				strTemp = (String)vReqItems.elementAt(iLoop+5);
				if(Double.parseDouble(strTemp) <= 0)
					strTemp = "";
			%>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"Already issued "," " + (String)vReqItems.elementAt(iLoop+2),"No Stock")%></td>
	</tr>
	<%} // end for loop%>
	<input type="hidden" name="item_count" value="<%=iCountItem%>">
    <tr>
      <td class="thinborder" height="25" colspan="2">
	      <strong>TOTAL ITEM(S) : <%=iCountItem%></strong></td>
      <td class="thinborder">&nbsp;</td>
      <!--
			<td class="thinborder">&nbsp;</td>
			-->
      <td class="thinborder">&nbsp;</td>
    </tr>
  </table>
  <!--
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="center">
        <a href="javascript:PageAction(1,0,'');"> <img src="../../../images/save.gif" border="0"></a> <font size="1" >click to save entry</font>
                <a href="javascript:CancelRecord();"> <img src="../../../images/cancel.gif" border="0"></a> <font size="1">click
          to cancel </font>

                <input type="text" name="req_no2" readonly size="2"
			style="background-color:#FFFFFF;border-width: 0px;"></td>
    </tr>
  </table>
	-->
<%}
}else{%>
 <input type="hidden" name="is_supply">
<%}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="cancelClicked" value="">
  <input type="hidden" name="strIndex" value="<%=WI.fillTextValue("strIndex")%>">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
