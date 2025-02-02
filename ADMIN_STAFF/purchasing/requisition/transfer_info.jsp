<%@ page language="java" import="utility.*,purchasing.Requisition, purchasing.PURSetting,
																 java.util.Vector" %>
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
	document.form_.pageAction.value = "";
	document.form_.forwardTo.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{		
    document.form_.forwardTo.value = "";
	document.form_.printPage.value = "";
	document.form_.pageReloaded.value = "1";
	document.form_.pageAction.value = "1";	
	this.SubmitOnce('form_');
}
function PageAction(strAction,strIndex){
	document.form_.pageAction.value = "";
	document.form_.forwardTo.value = "";
	document.form_.printPage.value = "";
	if(strAction == 0){
		var vProceed = confirm('Delete this requisition?');
		if(vProceed){
			document.form_.pageAction.value = strAction;
			document.form_.strIndex.value = strIndex;
			this.SubmitOnce('form_');
		}
	}
	else{
		document.form_.pageAction.value = strAction;
		document.form_.strIndex.value = strIndex;
		this.SubmitOnce('form_');	
	}
} 
function ForwardTo(){
	document.form_.forwardTo.value = "1";
	document.form_.pageAction.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
    document.form_.forwardTo.value = "";
	document.form_.pageAction.value = "";
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function OpenSearch(){
	document.form_.printPage.value = "";
	var pgLoc = "../requisition/requisition_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
function PageLoad(){
 	document.form_.req_no.focus();
}

function CheckAll()
{
	document.form_.printPage.value = "";
	var iMaxDisp = document.form_.item_count.value;
	if (iMaxDisp.length == 0)
		return;	
	if (document.form_.selAll.checked ){
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.transfer_'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.transfer_'+i+'.checked=false');
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%	
	String strTemp = null;
	boolean bolMyHome = false;	
	
	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;
		
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="request_item_print.jsp"/>
	<%return;}
	 if(WI.fillTextValue("forwardTo").equals("1")){%>
		<jsp:forward page="request_item.jsp"/>
	<%return;}

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
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}

strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){//for my home, request items... i doubt someone will look at this anyway... hehehe
			iAccessLevel  = 2;	
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
DBOperation dbOP = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-Requisition Info","transfer_info.jsp");
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
								
	Requisition REQ = new Requisition();	
	PURSetting purSetting = new PURSetting();
 	Vector vReqInfo = null;
	Vector vRequested = null;
	Vector vTransfer = null;	
	Vector vReqItems = null;
	Vector vRetResult = null;
	Vector vEmpDetails = null;
	String strErrMsg = null;	
	String strTemp2 = null;
	String strCIndex = null;
	String strDIndex = null;
	String strReqName = null;
	int iDefault = 0;
	int i = 0;
	int iCountItem = 1;
	String strSchCode = dbOP.getSchoolIndex();
	String[] astrReqType = {"New","Replacement"};
 
 	if(WI.fillTextValue("proceedClicked").equals("1")){	
		if(WI.fillTextValue("pageAction").length() > 0 && !(WI.fillTextValue("pageReloaded").equals("1"))){
			vRetResult = REQ.operateOnReqInfoTransfer(dbOP,request,Integer.parseInt(WI.fillTextValue("pageAction")));	
			if(vRetResult == null)
				strErrMsg = REQ.getErrMsg();
			else
				strErrMsg = "Operation successful";
		}
		
		if(vRetResult != null && vRetResult.size() > 0)
			vReqInfo = REQ.operateOnReqInfoTransfer(dbOP,request,4,(String)vRetResult.elementAt(0));
		else
			vReqInfo = REQ.operateOnReqInfoTransfer(dbOP,request,4);

		if(vReqInfo == null && WI.fillTextValue("req_no").length() > 0
							&& WI.fillTextValue("pageAction").length() < 1)
			strErrMsg = REQ.getErrMsg();
	
		vReqItems = REQ.operateOnItemIssuance(dbOP, request, 4);	
		if(vReqItems != null)	{
			vRequested = (Vector)vReqItems.elementAt(0);
			vTransfer = (Vector)vReqItems.elementAt(1);
		}	
			
 		if(bolMyHome){
			vEmpDetails = REQ.getEmployeeDetail(dbOP,request);
			if(vEmpDetails != null && vEmpDetails.size() > 0){
			  strCIndex = (String)vEmpDetails.elementAt(4);	
			  strDIndex = (String)vEmpDetails.elementAt(5);
			  strReqName = WI.formatName((String)vEmpDetails.elementAt(1),(String)vEmpDetails.elementAt(2),
			  							(String)vEmpDetails.elementAt(3),4);
			}
		}
	}		
%>
<form name="form_" method="post" action="transfer_info.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	  <tr bgcolor="#A49A6A"> 
	  <td height="25" colspan="2" align="center" bgcolor="#A49A6A"><font color="#FFFFFF"><strong>:::: 
      ITEM TRANSFER REQUEST PAGE ::::</strong></font></td>
	  </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="69%" height="25">&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%>        
        </font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="20%">Requisition No.</td>
      <td width="77%"><strong>
	  <%if(WI.fillTextValue("pageAction").equals("1") && vRetResult != null)
	  		strTemp = (String)vRetResult.elementAt(0);
	    else if(WI.fillTextValue("req_no").length() > 0)
	  		strTemp = WI.fillTextValue("req_no");
	  	else
			strTemp = "";
	  %>
        <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong>&nbsp; 
		<a href="javascript:OpenSearch();">
		<img src="../../../images/search.gif" border="0"></a>
		<a href="javascript:ProceedClicked();"> <img src="../../../images/form_proceed.gif" border="0"> 
      </a></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp; </td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%if(vReqInfo != null && vReqInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4" align="center"><strong>REQUISITION DETAILS </strong></td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="21%">Requisition No. :</td>
      <td width="29%"><strong><%=WI.fillTextValue("req_no")%></strong></td>
      <td width="15%">Requested By :</td>
      <td width="32%"> <strong><%=(String)vReqInfo.elementAt(3)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(2))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Date :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(7))%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
	<%if(((String)vReqInfo.elementAt(5)).equals("0")){%> 
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(10),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)+"/"+WI.getStrValue((String)vReqInfo.elementAt(8),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(10),"&nbsp;")%></strong></td>
    </tr>
  <%}%>		
	<input type="hidden" name="requested_by" value="<%=(String)vReqInfo.elementAt(3)%>">
	<input type="hidden" name="c_index_to" value="<%=(String)vReqInfo.elementAt(5)%>">
	<input type="hidden" name="d_index_to" value="<%=(String)vReqInfo.elementAt(6)%>">
	<input type="hidden" name="purpose" value="<%=(String)vReqInfo.elementAt(9)%>">
	<input type="hidden" name="date_needed" value="<%=WI.getStrValue((String)vReqInfo.elementAt(10))%>">	
 	  <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>	
  </table>
	<!--
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
     <tr bgcolor="#C78D8D">
      <td height="25">&nbsp;</td>
      <td colspan="2"><strong><font color="#FFFFFF">ITEM SOURCE LOCATION </font></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="21%">College</td>
			<%
				//strCIndex = WI.getStrValue(WI.fillTextValue("c_index_fr"),"0");
			%>
      <td width="76%">
			<select name="c_index_fr" onChange="ReloadPage();">
        <option value="0">N/A</option>
        <%//=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strCIndex, false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Department</td>
			<%			
				//strDIndex = WI.fillTextValue("d_index_fr");			
			%>			
      <td height="29">
        <select name="d_index_fr">
          <%// if(strCIndex != null && strCIndex.compareTo("0") != 0){%>
          <option value="">All</option>
          <%//}else{%>
					<option value="0">Select Office</option>
					<%//}%>
				<%//if (strCIndex == null || strCIndex.length() == 0 || strCIndex.compareTo("0") == 0) 
					//	strCIndex = " and (c_index = 0 or c_index is null) ";
					//else strCIndex = " and c_index = " +  strCIndex;
				%>
        <%//=dbOP.loadCombo("d_index","d_NAME"," from department where is_del = 0 " + strCIndex + 
					//								" order by d_name asc",strDIndex, false)%>
        </select></td>
    </tr>
	  <tr>
	    <td height="17" colspan="3"><hr size="1"></td>
    </tr>
  </table>	
	-->
	<%
 	if(vRequested != null && vRequested.size() > 0 && vReqInfo != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="25" align="center" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><font color="#FFFFFF"><strong>LIST OF REQUESTED ITEMS </strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td height="25" colspan="4" class="thinborder">Requested by :<strong><%=(String)vReqInfo.elementAt(3)%></strong></td>
    </tr>
    <tr> 
      <td width="12%" height="25" align="center" class="thinborder"><strong>QUANTITY</strong></td>
      <td width="63%" align="center" class="thinborder"><strong>PARTICULARS/ITEM DESCRIPTION</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>AVAILABLE</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>ENDORSE All <br>
          <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
      </strong></td>
    </tr>
    <%
	for(i = 0;i < vRequested.size();i+=10,iCountItem++){%>
	<tr> 
			<input type="hidden" name="item_req_index_<%=iCountItem%>" value="<%=vRequested.elementAt(i)%>">
			<input type="hidden" name="brand_index_<%=iCountItem%>" value="<%=WI.getStrValue((String)vRequested.elementAt(i+6))%>">
			<input type="hidden" name="item_index_<%=iCountItem%>" value="<%=vRequested.elementAt(i+7)%>">
			<input type="hidden" name="unit_index_<%=iCountItem%>" value="<%=vRequested.elementAt(i+8)%>">
			<input type="hidden" name="item_name_<%=iCountItem%>" value="<%=vRequested.elementAt(i+3)%>">			
      <td height="25" align="right" class="thinborder">
			<input name="qty_<%=iCountItem%>" type="text" value="<%=vRequested.elementAt(i+1)%>" 
			size="5" maxlength="5" readonly class="textbox_noborder" style="text-align:right">
			<%=vRequested.elementAt(i+2)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=vRequested.elementAt(i+3)%>-<%=vRequested.elementAt(i+4)%></td>
      <td align="right" class="thinborder"><%=WI.getStrValue((String)vRequested.elementAt(i+9),"",(String)vRequested.elementAt(i+2),"&nbsp;")%>&nbsp;</td>
      <td align="center" class="thinborder"> 
  <input type="checkbox" name="transfer_<%=iCountItem%>" value="1"></td>
	</tr>
	<%} // end for loop%>
	<input type="hidden" name="item_count" value="<%=iCountItem - 1%>">
    <tr> 
      <td class="thinborder" height="25" colspan="2">
	      <strong>TOTAL ITEM(S) : <%=iCountItem-1%></strong></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4"></td>
    </tr>	
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30" colspan="4"><div align="center"><a href="javascript:PageAction(1,0);"><img src="../../../images/save.gif" border="0"></a> 
          <font size="1" >click to save entry</font></div></td>
    </tr>
  </table>
<%}
}%>  	
	<%if(vTransfer != null && vTransfer.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    
    <tr>
      <td height="25" colspan="2" align="center" class="thinborder"><strong>LIST OF  ITEMS ALREADY ISSUED</strong></td>
    </tr>
    <tr> 
      <td width="14%" height="25" align="center" class="thinborder"><strong>QUANTITY</strong></td>
      <td width="72%" align="center" class="thinborder"><strong>PARTICULARS/ITEM DESCRIPTION</strong></td>
    </tr>
    <%iCountItem = 1;
	for(i = 0;i < vTransfer.size();i+=9,iCountItem++){%>
	<tr> 
      <td height="25" align="right" class="thinborder"><%=vTransfer.elementAt(i+1)%>
			<%=vTransfer.elementAt(i+2)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=vTransfer.elementAt(i+3)%>-<%=vTransfer.elementAt(i+4)%></td>
    </tr>
	<%} // end for loop%>
    <tr> 
      <td class="thinborder" height="25" colspan="2">
	      <strong>TOTAL ITEM(S) : <%=iCountItem-1%></strong></td>
    </tr>
  </table>
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>    
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="pageAction" value="<%=WI.fillTextValue("pageAction")%>">
  <input type="hidden" name="strIndex" value="<%=WI.fillTextValue("strIndex")%>">
  <input type="hidden" name="forwardTo" value="">
  <input type="hidden" name="pageReloaded" value="">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="request_stage" value="1">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
