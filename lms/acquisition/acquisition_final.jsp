<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script src="../../jscript/common.js"></script>
<script language="javascript">
function OpenSearch() {
	var pgLoc = "../search/search_simple.jsp?opner_info=form_.accession_no&opner_info2=form_.reload_main&opner_info2_val=1";
	var win=window.open(pgLoc,"PrintWindow",'width=950,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateSupplier() {
	var pgLoc = "./supplier.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=950,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%@ page language="java" import="utility.*,lms.LmsAcquision,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	String strUserIndex  = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Acquisition".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}

//end of authenticaion code.

	try {
		dbOP = new DBOperation();
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

boolean bolIsFinal = false;

LmsAcquision lmsAcq = new LmsAcquision();
Vector vRetResult   = null; 
int iAcqSaveStat = -1;//-1 nothing saved.. 0 = only main talbe saved, 1 = main and all book detail saved, 2 = main and partial book detail saved.

if(WI.fillTextValue("acq_no").length() > 0) {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(lmsAcq.operareOnAcquisitionFinal(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = lmsAcq.getErrMsg();
		else	
			strErrMsg = "Request Processed Successfully.";
	}
	vRetResult = lmsAcq.operareOnAcquisitionFinal(dbOP, request, 3);
	
	if(vRetResult == null)
		strErrMsg = lmsAcq.getErrMsg();
	else	
		iAcqSaveStat = Integer.parseInt((String)vRetResult.remove(0));
}
%>
<body bgcolor="#FAD3E0" onLoad="document.form_.acq_no.focus();">
<form action="./acquisition_final.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#0D3371">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>:::: ACQUISITION - ACTUAL COSTING ::::</strong></font></div></td>
    </tr>
  </table>
<jsp:include page="./inc.jsp?pgIndex=5"></jsp:include>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	  <tr>
		<td colspan="3" style="font-size:13px; font-weight:bold; color:#FF0000"> &nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
	  </tr>
	  <tr>
		<td width="12%" height="24">Acquisition # </td>
		<td width="88%" colspan="2">
			<input name="acq_no" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("acq_no")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="submit" name="_12" value="Reload Page" onClick="document.form_.page_action.value='';">
			
			&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-size:14px; font-weight:bold; color:#FF0000">
			<%
				if(iAcqSaveStat == 0) 
					strTemp = "Acquistion Main info is saved. Please save individual book info";
				else if(iAcqSaveStat == 1)
					strTemp = "Acquisition complete Information is saved.";
				else if(iAcqSaveStat == 2)
					strTemp = "Acquisition Main info is saved and only few book details are saved.";
				else
					strTemp = "";
			%>
			<%=strTemp%>
			</font>
		</td>
	  </tr>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	  <tr>
		<td height="24">School Yr </td>
		<td colspan="2"><%=vRetResult.elementAt(6)%></td>
	  </tr>
	  <tr>
	    <td height="24">Course </td>
	    <td colspan="2"><%=vRetResult.elementAt(8)%></td>
      </tr>
<%}%>
	  <tr>
	    <td colspan="3"><hr size="1"></td>
      </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	  	<tr>
			<td width="15%">PO Number</td>
			<td width="15%">
<%
strTemp = (String)vRetResult.elementAt(2);
if(strTemp == null)
	strTemp = WI.fillTextValue("po_no");
if(strTemp == null)
	strTemp = "";
%>
			<input name="po_no" type="text" size="8" maxlength="16" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td width="15%" align="right">DR Number&nbsp;&nbsp;</td>
			<td width="15%">
<%
strTemp = (String)vRetResult.elementAt(3);
if(strTemp == null)
	strTemp = WI.fillTextValue("dr_no");
if(strTemp == null)
	strTemp = "";
%>
			<input name="dr_no" type="text" size="8" maxlength="16" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td width="15%" align="right">Tot Amt&nbsp;&nbsp;</td>
			<td width="25%">
<%
strTemp = (String)vRetResult.elementAt(0);
if(strTemp != null && strTemp.length() > 0) {
	if(strTemp != null && strTemp.length() > 0)	
		strTemp = ConversionTable.replaceString(strTemp, ",","");

}
else
	strTemp = WI.fillTextValue("acq_cost");
%>
 			<input name="acq_cost" type="text" size="10" maxlength="16" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyIntegerExtn('form_','acq_cost','.');style.backgroundColor='white'"
				 onKeyUp="AllowOnlyIntegerExtn('form_','acq_cost','.');">			</td>
		</tr>
	  	<tr>
	  	  <td>Purchase Remarks </td>
	  	  <td colspan="5">
<%
strTemp = (String)vRetResult.elementAt(5);
if(strTemp == null)
	strTemp = WI.fillTextValue("remarks");
if(strTemp == null)
	strTemp = "";
%>
<textarea class="textbox" name="remarks" cols="75" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
  	    </tr>
	  	<tr>
	  	  <td>&nbsp;</td>
	  	  <td colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  	<input type="submit" name="_" value="Save Acquisition Main Info" onClick="document.form_.page_action.value='1';">
		  </td>
  	    </tr>
	  	<tr>
	  	  <td>&nbsp;</td>
	  	  <td colspan="5">&nbsp;</td>
  	    </tr>
	  </table>
	

	  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#CCCCCC">
		  <tr bgcolor="#9DB6F4">
			<td height="25" colspan="9" align="center" class="thinborder"><font color="#FFFFFF" ><strong>:::: Final Costing of Acquistion ::::</strong></font></td>
		  </tr>
		  <tr bgcolor="#C6D3F4" align="center" style="font-weight:bold">
			<td width="5%" class="thinborder">Count</td>
			<td width="20%" height="25" class="thinborder">Author</td>
			<td width="25%" class="thinborder">Title</td>
			<td width="7%" class="thinborder">Edition</td>
			<td width="8%" class="thinborder">Unit Price</td>
			<td width="5%" class="thinborder">Qty</td>
			<td width="10%" class="thinborder">Actual Cost </td>
			<td width="15%" class="thinborder">Discount per book </td>
			<td width="5%" class="thinborder">Select</td>
		  </tr>
		<%
		boolean bolIsSaved = false;
		int j = 0;//System.out.println(vRetResult);
		for(int i = 9; i < vRetResult.size(); i += 15,++j){
		if(vRetResult.elementAt(i + 14) == null)
			bolIsSaved = false;
		else	
			bolIsSaved = true;
		%>
		  <tr>
			<td class="thinborder"><%=j + 1%>.</td>
			<td height="20" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
			<td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
			<%strTemp = (String)vRetResult.elementAt(i + 2);
				if(strTemp != null)
					strTemp = (String)vRetResult.elementAt(i + 2);
				else
					strTemp = "";
			%>
			<td class="thinborder">&nbsp;<%=strTemp%></td>
			<td class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 6), true)%></td>
			<td class="thinborder" align="right"><%=vRetResult.elementAt(i + 5)%> &nbsp;</td>
			<td class="thinborder" align="center">
<%
if(bolIsSaved) {
	strTemp = (String)vRetResult.elementAt(i + 11);
	if(strTemp != null)
		strTemp = strTemp.substring(0,strTemp.length() - 2);
}
else	
	strTemp = (String)vRetResult.elementAt(i + 9);
if(strTemp == null) 
	strTemp = "";
else if(strTemp.length() > 0)	
	strTemp = ConversionTable.replaceString(strTemp, ",","");
%>
				<input name="actual_price_<%=j%>" type="text" size="8" maxlength="12" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="AllowOnlyIntegerExtn('form_','actual_price_<%=j%>','.');style.backgroundColor='white'" style="font-size:11px;"
				onKeyUp="AllowOnlyIntegerExtn('form_','actual_price_<%=j%>','.');"></td>
			<td class="thinborder" align="center">
<%
if(bolIsSaved)
	strTemp = (String)vRetResult.elementAt(i + 12);
else	
	strTemp = (String)vRetResult.elementAt(i + 7);
if(strTemp == null) 
	strTemp = "";
%>
			<select name="disc_unit_<%=j%>" style="font-size:10px;">
				<option value="0">Amt</option>
				<%
				if(strTemp.equals("1"))
					strTemp = " selected";
				else
					strTemp = "";
				%><option value="1"<%=strTemp%>>%ge</option>
			</select>
<%
if(bolIsSaved)
	strTemp = (String)vRetResult.elementAt(i + 13);
else	
	strTemp = (String)vRetResult.elementAt(i + 8);
if(strTemp == null) 
	strTemp = "";
else if(strTemp.length() > 0)
	strTemp = strTemp.substring(0,strTemp.length() - 2);
%>
			  <input name="disc_<%=j%>" type="text" size="6" maxlength="12" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="AllowOnlyIntegerExtn('form_','disc_<%=j%>','.');style.backgroundColor='white'" style="font-size:11px;"
				onKeyUp="AllowOnlyIntegerExtn('form_','disc_<%=j%>','.');">			</td>
			<td class="thinborder" align="center">
				<input type="checkbox" name="acq_dtls_<%=j%>" value="<%=vRetResult.elementAt(i)%>" checked="checked" readonly="yes">					</td>
		  </tr>
		<%}%>
		<input type="hidden" name="max_disp" value="<%=j%>">
		  <tr>
			<td height="20" colspan="9" align="center" class="thinborder">
			<input type="submit" name="_1" value="Save Information" onClick="document.form_.page_action.value='12';"></td>
		  </tr>
	  </table>	
<%}//show only if vRetResult is not null %>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>