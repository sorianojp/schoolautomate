<%@ page language="java" import="utility.*, Accounting.TsuneishiDC, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsForwarded = WI.fillTextValue("is_forwarded").equals("1");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Update DC Note</title>
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function UpdateAttentionList(){
		var pgLoc = "../SOA/SOA_attention_list.jsp?opner_form_name=form_";	
		var win=window.open(pgLoc,"UpdateAttentionList",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function loadPosition(){
		var objAddr=document.getElementById("load_position");
 		var objAttention = document.form_.attention[document.form_.attention.selectedIndex].value;
		
		this.InitXmlHttpObject(objAddr, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20006&ref="+objAttention;
		this.processRequest(strURL);
	}
	
	function GoBack(){
		location = "./create_dc_note.jsp";
	}
	
	function ReloadPage(){
		document.form_.attention.value = "";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.print_page.value = "";
		document.form_.amount.value = "";
		document.form_.desc.value = "";
		document.form_.submit();
	}
	
	function PrintAttachment(){
		document.form_.print_page.value = "2";
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}

	function AjaxMapDCNumber() {
		var strDCNumber = document.form_.dc_number.value;
		var objCOAInput = document.getElementById("coa_info");
		if(strDCNumber.length < 3) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20009&dc_number="+escape(strDCNumber);
		this.processRequest(strURL);
	}

	function updateDCNumber(strDCIndex, strDCNumber){
		document.form_.print_page.value = "";
		document.form_.dc_number.value = strDCNumber;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.submit();
	}
	
	function GetDCNumber(){
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this D/C note detail?'))
				return;
		}
		
		document.form_.print_page.value = "";
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.dc_number.focus();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").equals("1")){%>
		<jsp:forward page="./update_dc_note_print.jsp" />
	<% 
		return;}
		
	if (WI.fillTextValue("print_page").equals("2")){%>
		<jsp:forward page="./update_dc_note_print_attachment.jsp" />
	<% 
		return;}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
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
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","update_dc_note.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}	
	
	boolean bolIsPaid = false;
	int iSearchResult = 0;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vDCInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	TsuneishiDC tsuDC = new TsuneishiDC();
	
	if(WI.fillTextValue("dc_number").length() > 0){
		vDCInfo = tsuDC.getDCInformation(dbOP, request);
		if(vDCInfo == null)
			strErrMsg = tsuDC.getErrMsg();
		else{
			if((String)vDCInfo.elementAt(13) != null)
				bolIsPaid = true;
			
			strTemp = WI.fillTextValue("page_action");
			if(strTemp.length() > 0){
				if(tsuDC.operateOnDCNoteDetails(dbOP, request, Integer.parseInt(strTemp), (String)vDCInfo.elementAt(0)) == null)
					strErrMsg = tsuDC.getErrMsg();
				else{
					if(strTemp.equals("0"))
						strErrMsg = "D/C note detail successfully removed.";
					if(strTemp.equals("1"))
						strErrMsg = "D/C note detail successfully recorded.";
					if(strTemp.equals("2"))
						strErrMsg = "D/C note detail successfully edited.";
					
					strPrepareToEdit = "0";
				}
			}
			
			vRetResult = tsuDC.operateOnDCNoteDetails(dbOP, request, 4, (String)vDCInfo.elementAt(0));
		
			if(strPrepareToEdit.equals("1")){
				vEditInfo = tsuDC.operateOnDCNoteDetails(dbOP, request, 3, (String)vDCInfo.elementAt(0));
				if(vEditInfo == null)
					strErrMsg = tsuDC.getErrMsg();
			}
		}
	}
	
%>
<body bgcolor="#D2AE72" onload="FocusField();">
<form name="form_" action="./update_dc_note.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: D/C NOTE PARTICULARS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		    <td align="right">
				<%if(bolIsForwarded){%>
					<a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0" /></a>
				<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>D/C No: </td>
			<td>
				<%if(!bolIsForwarded){%>
					<input name="dc_number" type="text" size="16" value="<%=WI.fillTextValue("dc_number")%>" class="textbox"
						onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapDCNumber();">
				<%}else{%>
					<input type="hidden" name="dc_number" value="<%=WI.fillTextValue("dc_number")%>" />
					<strong><font size="3" color="#FF0000"><%=WI.fillTextValue("dc_number")%></font></strong>
				<%}%></td>
			<td colspan="2" valign="top"><label id="coa_info" style="position:absolute; width:300px"></label></td>
		</tr>
		<tr>
			<td height="15" width="3%">&nbsp;</td>
		    <td width="17%">&nbsp;</td>
		    <td width="20%">&nbsp;</td>
		    <td width="45%">&nbsp;</td>
		    <td width="15%">&nbsp;</td>
		</tr>
		<%if(!bolIsForwarded){%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="3">
				<a href="javascript:GetDCNumber();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to view D/C details. </font></td>
	    </tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
		<%}%>
	</table>
	
<%if(vDCInfo != null && vDCInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="5"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="17%">D/C Number: </td>
		    <td colspan="3"><%=(String)vDCInfo.elementAt(2)%></td>
		    <input type="hidden" name="dc_index" value="<%=(String)vDCInfo.elementAt(0)%>" />
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>D/C Date: </td>
		    <td width="30%"><%=(String)vDCInfo.elementAt(1)%></td>
		    <td width="17%">Currency:</td>
		    <td width="33%"><%=(String)vDCInfo.elementAt(9)%> (<%=(String)vDCInfo.elementAt(10)%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Charge To: </td>
		    <td colspan="3"><%=(String)vDCInfo.elementAt(4)%></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Address:</td>
		    <td colspan="3"><%=(String)vDCInfo.elementAt(7)%></td>
	    </tr>
		<tr>
			<td height="15" colspan="5"><hr size="1" /></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Amount:</td>
			<td width="80%">
				<%
					if (vEditInfo != null && vEditInfo.size()>0){
						strTemp = (String)vEditInfo.elementAt(2);
						strTemp = CommonUtil.formatFloat(strTemp, true);
						strTemp = ConversionTable.replaceString(strTemp, ",", "");
					
						if(strTemp.equals("0"))
							strTemp = "";
					}
					else		
						strTemp = WI.fillTextValue("amount");
				%>
				<input name="amount" type="text" class="textbox" value="<%=strTemp%>" size="10" maxlength="12"
					onkeyup="AllowOnlyFloat('form_','amount')" onfocus="style.backgroundColor='#D3EBFF'"
					onblur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Details:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("desc");
				%>
		  		<input type="text" name="desc" value="<%=strTemp%>" class="textbox" size="64" maxlength="256"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
	<%if(((String)vDCInfo.elementAt(5)).equals("THI")){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Attention:</td>
		  	<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(3));
					else
						strTemp = WI.fillTextValue("attention");
				%>
				<select name="attention" onChange="loadPosition();">
          			<option value="">Select Attention</option>
          			<%=dbOP.loadCombo("attention_index","attention_name", " from ac_sa_attention_list where is_valid = 1", strTemp,false)%> 
        		</select>
			  	&nbsp;
			  	<a href="javascript:UpdateAttentionList();"><img src="../../../images/update.gif" border="0"></a>
			  	<font size="1">Click to update attention list</font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Position:</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(5));
				else{
					strTemp = WI.fillTextValue("attention");
					if(strTemp.length() > 0){
						strTemp = " select position from ac_sa_attention_list where is_valid = 1 and attention_index= "+strTemp;
						strTemp = dbOP.getResultOfAQuery(strTemp, 0);
					}
					else
						strTemp = "";
				}
			%>
			<td><label id="load_position"><%=strTemp%></label></td>
		</tr>
	<%}%>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
			<%if(!bolIsPaid){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save D/C details.</font>
				    <%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit D/C detail.</font>
					    <%}
				}%>
				<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0" /></a>
			<%}else{%>
				Save/edit operations not allowed. D/C note already paid.
			<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">
			<%if(((String)vDCInfo.elementAt(5)).equals("THI")){%>
				<a href="javascript:PrintAttachment();"><img src="../../../images/print.gif" border="0" /></a>
				<font size="1">Click to print attachment.</font>&nbsp;
			<%}%>
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
				<font size="1">Click to print D/C details.</font>&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="4" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: D/C NOTE DETAILS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="45%" align="center" class="thinborder"><strong>Details</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Attention</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
		<%for(int i = 0; i < vRetResult.size(); i+=7){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">
			<%if(((String)vDCInfo.elementAt(5)).equals("THI")){%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i+4), "", "<br>", "&nbsp;")%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i+5), "", "", "&nbsp;")%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "<br>", "", "")%>
			<%}else{%>
				N/A
			<%}%></td>
		    <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+2)%>&nbsp;&nbsp;</td>
		    <td align="center" class="thinborder">
			<%if(!bolIsPaid){//if not yet paid
				if(iAccessLevel > 1){%>					
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
					<%}%>
					<br />
				<%}else{%>
					Not authorized.
				<%}
			}else{%>
				Not allowed.
			<%}%></td>
		</tr>
		<%}%>
	</table>
	<%}
}%>	

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page" />
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>