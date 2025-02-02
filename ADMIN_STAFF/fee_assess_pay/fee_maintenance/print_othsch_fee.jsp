<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.textbox_noborder2{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;		 
		border:none;
		text-align:right;

	}
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ViewAll()
{
	this.SubmitOnce('form_');
}
function PrintPg() {
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();	
}

function SetFocusIndex(strIndex){
	document.form_.focus_index.value = strIndex;
}

function CheckUpdate(strIndex){

/** moved to ajax call. 
	if (eval('document.form_.misc'+strIndex+'.value != document.form_.misc_o'+strIndex+'.value')){
		eval('document.form_.info_index.value = document.form_.info_index'+strIndex+'.value');
		eval('document.form_.amount_new.value = document.form_.misc'+strIndex+'.value');
		this.SubmitOnce('form_');
	}
**/
	var strNewAmount = "";
	var strOldAmount = "";
	var strInfoIndex = "";
	
	eval('strNewAmount=document.form_.misc'+strIndex+'.value');
	eval('strOldAmount=document.form_.misc_o'+strIndex+'.value');
	eval('strInfoIndex=document.form_.info_index'+strIndex+'.value');
	
	if (strNewAmount != strOldAmount){
		document.form_.info_index.value = strInfoIndex;
		document.form_.amount_new.value = strNewAmount;
		///this.SubmitOnce('form_');
		//changed to ajax call..
		var objAmount;
		eval('objAmount=document.form_.misc'+strIndex);
				 
		this.InitXmlHttpObject(objAmount, 1);//I want to get value in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=101&amount_new="+strNewAmount+
		"&info_index="+strInfoIndex+"&is_tuition=3";
		this.processRequest(strURL);
			
	}

}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.FAFeeMaintenance"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-Copy Fee","print_othsch_fee.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"print_othsch_fee.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

FAFeeMaintenance FAPrint = new FAFeeMaintenance();
Vector vRetResult = null;


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String strReadOnly = "";

if (!strSchCode.startsWith("CPU")){
	strReadOnly = "  ";
}


if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = FAPrint.printOthSchFee(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"));
	if(vRetResult == null)
		strErrMsg = FAPrint.getErrMsg();		
}


boolean bolIsSWU = strSchCode.startsWith("SWU");

%>


<form name="form_" action="./print_othsch_fee.jsp" method="post">
<input type="hidden" name="focus_index" value="<%=WI.fillTextValue("focus_index")%>">
<input type="hidden" name="amount_new" value="">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" align="center"><font color="#FFFFFF"><strong>:::: 
        PRINT OTHER SCHOOL FEE ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td height="22" colspan="2"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="3%" height="22">&nbsp;</td>
      <td width="13%">School year</td>
      <td width="84%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href='javascript:ViewAll();'><img src="../../../images/view.gif" border="0"></a> 
        <font size="1">View Tuition Fee detail.</font> </td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right">
	  <%if(vRetResult != null && vRetResult.size() > 0) {%>
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1"> 
        Print page.</font>&nbsp;&nbsp;&nbsp;&nbsp;
	  <%}%>
	  </td>
    </tr>
  </table>
 <%
 if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="22" colspan="9" align="center" bgcolor="#DDDDDD" class="thinborder"><font size="1"><b>LIST 
        OF OTHER SCHOOL FEE FOR <%=WI.fillTextValue("sy_from") +" - "+WI.fillTextValue("sy_to")%></b></font></td>
    </tr>
    <tr> 
      <td width="51%" height="22" class="thinborder"><strong>FEE NAME</strong></td>
<%if(bolIsSWU){%>
      <td width="5%" class="thinborder"><strong>Is U-Store </strong></td>
<%}%>
      <td width="7%" class="thinborder"><strong>ALL</strong></td>
      <td width="7%" class="thinborder"><strong>1st Year</strong></td>
      <td width="7%" class="thinborder"><strong>2nd Year</strong></td>
      <td width="7%" class="thinborder"><strong>3rd Year</strong></td>
      <td width="7%" class="thinborder"><strong>4th Year</strong></td>
      <td width="7%" class="thinborder"><strong>5th Year</strong></td>
      <td width="7%" class="thinborder"><strong>6th Year</strong></td>
    </tr>
    <%boolean bolCCodeShoudNull = false;//it should be null, if it prints atleast one result already.
int p = 0;//p is used to insert &nbsp;
int iCtr = 0;
 //System.out.println("Printing ::................................................................................... "+vRetResult);
for(int i = 0; i < vRetResult.size();){bolCCodeShoudNull = false;%>
    <tr> 
      <td height="22" class="thinborder"> <%=WI.getStrValue((String)vRetResult.elementAt(i))%> </td>
<%if(bolIsSWU){
strTemp = WI.getStrValue(vRetResult.elementAt(i + 4));
if(strTemp.equals("1"))
	strTemp = "<font style='font-size:16px; font-weight:bold'>Y</font>";
else	
	strTemp = "&nbsp;";
%>
      <td class="thinborder" align="center"><%=strTemp%></td>
<%}%>
      <td class="thinborder"> <%if( ((String)vRetResult.elementAt(i + 1)).compareTo("0") == 0) {bolCCodeShoudNull = true;%> 
  		<input name="misc<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
			onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" 
			value="<%=(String)vRetResult.elementAt(i + 2)%>" 		
			onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
		<input type="hidden" name="misc_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 2)%>"> 
		<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 3)%>">		
	  
	  <%i += 5; p = i;}else{%> &nbsp; <%}%> </td>
      <td class="thinborder"> <%p = 0;if(i < vRetResult.size() && ((String)vRetResult.elementAt(i + 1)).equals("1"))  {
	  	if( (bolCCodeShoudNull && vRetResult.elementAt(i) == null) || !bolCCodeShoudNull){bolCCodeShoudNull = true;%> 
  		<input name="misc<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
			onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" 
			value="<%=(String)vRetResult.elementAt(i + 2)%>" 		
			onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
		<input type="hidden" name="misc_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 2)%>"> 
		<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 3)%>">
		
		<%i += 5;p = i;}}if(i != p){p = i;%> &nbsp; <%}%> </td>
      <td class="thinborder"> <%p = 0;if(i < vRetResult.size() && ((String)vRetResult.elementAt(i + 1)).equals("2"))  {
	  	if( (bolCCodeShoudNull && vRetResult.elementAt(i) == null) || !bolCCodeShoudNull){bolCCodeShoudNull = true;%> 
  		<input name="misc<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
			onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" 
			value="<%=(String)vRetResult.elementAt(i + 2)%>" 		
			onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
		<input type="hidden" name="misc_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 2)%>"> 
		<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 3)%>">
		
		<%i += 5;p = i;}}if(i != p){p = i;%> &nbsp; <%}%> </td>
      <td class="thinborder"> <%p = 0;if(i < vRetResult.size() && ((String)vRetResult.elementAt(i + 1)).equals("3"))  {
	  	if( (bolCCodeShoudNull && vRetResult.elementAt(i) == null) || !bolCCodeShoudNull){bolCCodeShoudNull = true;%> 
  		<input name="misc<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
			onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" 
			value="<%=(String)vRetResult.elementAt(i + 2)%>" 		
			onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
		<input type="hidden" name="misc_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 2)%>"> 
		<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 3)%>">
		
		<%i += 5;p = i;}}if(i != p){p = i;%> &nbsp; <%}%> </td>
      <td class="thinborder"> <%p = 0;if(i < vRetResult.size() && ((String)vRetResult.elementAt(i + 1)).equals("4"))  {
	  	if( (bolCCodeShoudNull && vRetResult.elementAt(i) == null) || !bolCCodeShoudNull){bolCCodeShoudNull = true;%> 
  		<input name="misc<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
			onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" 
			value="<%=(String)vRetResult.elementAt(i + 2)%>" 		
			onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
		<input type="hidden" name="misc_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 2)%>"> 
		<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 3)%>">
		
		<%i += 5;p = i;}}if(i != p){p = i;%> &nbsp; <%}%> </td>
      <td class="thinborder"> <%p = 0;if(i < vRetResult.size() && ((String)vRetResult.elementAt(i + 1)).equals("5"))  {
	  	if( (bolCCodeShoudNull && vRetResult.elementAt(i) == null) || !bolCCodeShoudNull){bolCCodeShoudNull = true;%> 
  		<input name="misc<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
			onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" 
			value="<%=(String)vRetResult.elementAt(i + 2)%>" 		
			onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
		<input type="hidden" name="misc_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 2)%>"> 
		<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 3)%>">
		
		<%i += 5;p = i;}}if(i != p){p = i;%> &nbsp; <%}%> </td>
      <td class="thinborder"> <%p = 0;if(i < vRetResult.size() && ((String)vRetResult.elementAt(i + 1)).equals("6"))  {
	  	if( (bolCCodeShoudNull && vRetResult.elementAt(i) == null) || !bolCCodeShoudNull){bolCCodeShoudNull = true;%> 
  		<input name="misc<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
			onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" 
			value="<%=(String)vRetResult.elementAt(i + 2)%>" 		
			onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
		<input type="hidden" name="misc_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 2)%>"> 
		<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 3)%>">
		
		<%i += 5;p = i;}}if(i != p){p = i;%> &nbsp; <%}%> </td>
    </tr>
    <%}%>
  </table>
 <%}//only if vRetResult != null;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr bgcolor="#FFFFFF">
      <td height="22" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="22" colspan="9">&nbsp;</td>
    </tr>
  </table>
<script language="javascript">
	if (document.form_.focus_index.value.length > 0) 
		eval("document.form_.misc" + document.form_.focus_index.value +".focus()");
</script>

<input type="hidden" name="info_index" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
