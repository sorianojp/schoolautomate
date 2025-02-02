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
	var strNewAmount = "";
	var strOldAmount = "";
	var strInfoIndex = "";
	
	eval('strNewAmount=document.form_.tuition'+strIndex+'.value');
	eval('strOldAmount=document.form_.tuition_o'+strIndex+'.value');
	eval('strInfoIndex=document.form_.info_index'+strIndex+'.value');
	
	if (strNewAmount != strOldAmount){
		document.form_.info_index.value = strInfoIndex;
		document.form_.amount_new.value = strNewAmount;
		///this.SubmitOnce('form_');
		//changed to ajax call..
		var objAmount;
		eval('objAmount=document.form_.tuition'+strIndex);
				 
		this.InitXmlHttpObject(objAmount, 1);//I want to get value in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=101&amount_new="+strNewAmount+
		"&info_index="+strInfoIndex+"&is_tuition=1";
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
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-Copy Fee","print_tuition_fee.jsp");
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
														"print_tuition_fee.jsp");
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
FAPrint.setHTTPReq(request);
Vector vRetResult = null;
Vector vExemptedSub = null;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String strReadOnly = null;
boolean bolIsCPU =strSchCode.startsWith("CPU"); 
if (!bolIsCPU) {
	strReadOnly = " readonly ";
}else{
	strReadOnly = "";
}


if(WI.fillTextValue("sy_from").length() > 0) {
	
	if (WI.fillTextValue("info_index").length() > 0
		&& WI.fillTextValue("amount_new").length() > 0) {
/** Changed to Ajax Call. 
		String strAmount = WI.fillTextValue("amount_new");
		try{
			strAmount = ConversionTable.replaceString(strAmount,",","");
			Float.parseFloat(strAmount);
			dbOP.executeUpdateWithTrans("update fa_tution_fee set amount =" + strAmount + 
				", last_mod_by = " + (String)request.getSession(false).getAttribute("userIndex") +
				", last_mod_date = '" + WI.getTodaysDate() + 
				"' where tution_fee_index = " + WI.fillTextValue("info_index"),
				null,null, false);
			
//			System.out.println("update fa_tution_fee set amount =" + strAmount + 
//				", last_mod_by = " + (String)request.getSession(false).getAttribute("userIndex") +
//				", last_mod_date = '" + WI.getTodaysDate() + 
//				"' where tution_fee_index = " + WI.fillTextValue("info_index"));
			
			
		}catch(NumberFormatException nfe){
			strErrMsg = " Invalid tuition : " + strAmount;
		}
		
**/
	}
	

	vRetResult = FAPrint.printTuitionFee(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"));
	if(vRetResult == null)
		strErrMsg = FAPrint.getErrMsg();		
}
String strIDSYRange = WI.fillTextValue("id_sy_range");
if(strIDSYRange.length() > 0) {
	strIDSYRange = "select RANGE_SY_FROM, RANGE_SY_TO from FA_CIT_IDRANGE where ID_RANGE_INDEX = "+strIDSYRange;
	java.sql.ResultSet rs = dbOP.executeQuery(strIDSYRange);
	if(rs.next()) {
		strIDSYRange = "( For Batch : "+rs.getString(1) + " - "+ rs.getString(2) + ") ";
	}
	rs.close();
}

String strSYFrom = WI.fillTextValue("sy_from");

if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");

%>
<form name="form_" action="./print_tuition_fee.jsp" method="post">
<input type="hidden" name="focus_index" value="<%=WI.fillTextValue("focus_index")%>">
<input type="hidden" name="amount_new" value="">


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" align="center"><font color="#FFFFFF"><strong>:::: PRINT TUITION 
        FEE ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td height="22" colspan="2"><label id="errMsg"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></label></td>
    </tr>
    <tr> 
      <td width="3%" height="22">&nbsp;</td>
      <td width="13%">School year</td>
      <td width="84%"> 
	  	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
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
<%if(strSchCode.startsWith("CIT")){%>
    <tr>
      <td height="22">&nbsp;</td>
      <td>Applicable SY Range<font style="font-weight:bold; color:#FF0000">*</font></td>
      <td>
	  <select name="id_sy_range" onChange="ReloadPage();">
          <%=dbOP.loadCombo("ID_RANGE_INDEX","RANGE_SY_FROM,RANGE_SY_TO"," from FA_CIT_IDRANGE where IS_ACTIVE_RECORD=1 and eff_fr_sy = "+strSYFrom+" order by RANGE_SY_FROM asc", WI.fillTextValue("id_sy_range"), false)%> 
	  </select>
<strong><a href="javascript:ViewAll();"><img src="../../../images/refresh.gif" border="0"></a><font size="1">click 
        to refresh page</font></strong>	  
	  
	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href='javascript:ViewAll();'><img src="../../../images/view.gif" border="0"></a> 
        <font size="1">View Tuition Fee detail.</font> 
		&nbsp;&nbsp;
		<input type="checkbox" name="set_xls" value="checked" <%=WI.fillTextValue("set_xls")%>> set .xls compatible
		</td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right">
	  <% if(vRetResult != null && vRetResult.size() > 0) {%>
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1"> 
        Print page.</font>&nbsp;&nbsp;&nbsp;&nbsp;
	  <%}%>	  </td>
    </tr>
  </table>
 <%
if(vRetResult != null && vRetResult.size() > 0) {

boolean bolSetXLS = false;
if(WI.fillTextValue("set_xls").length() > 0) 
	bolSetXLS = true;

  vExemptedSub = (Vector)vRetResult.remove(0);%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="22" colspan="10" align="center" bgcolor="#DDDDDD" class="thinborder"><font size="1"><b>LIST 
        OF TUITION FEE FOR <%=WI.fillTextValue("sy_from") +" - "+WI.fillTextValue("sy_to")%>
		<%=WI.getStrValue(strIDSYRange)%>
		</b></font></td>
    </tr>
    <tr> 
      <td width="35%" height="22" class="thinborder">&nbsp;</td>
      <td width="10%" class="thinborder"><strong>Fee Type</strong></td>
      <td width="6%" class="thinborder"><strong>Compute Per Hr?</strong></td>
      <td width="7%" class="thinborder"><strong>ALL</strong></td>
      <td width="7%" class="thinborder"><strong>1st Year</strong></td>
      <td width="7%" class="thinborder"><strong>2nd Year</strong></td>
      <td width="7%" class="thinborder"><strong>3rd Year</strong></td>
      <td width="7%" class="thinborder"><strong>4th Year</strong></td>
      <td width="7%" class="thinborder"><strong>5th Year</strong></td>
      <td width="7%" class="thinborder"><strong>6th Year</strong></td>
    </tr>
    <%boolean bolCCodeShoudNull = false;//it should be null, if it prints atleast one result already.
	boolean bolIsPerSub = false;
	int p = 0;//p is used to insert &nbsp;
	int iCtr = 0; 
 //System.out.println("Printing ::................................................................................... "+vRetResult);
for(int i = 0; i < vRetResult.size();){bolCCodeShoudNull = false;
	if( !bolIsPerSub && ((String)vRetResult.elementAt(i)).equals("1")) {bolIsPerSub = true;%>
    <tr> 
      <td height="22" colspan="10" align="center" bgcolor="#DDDDDD" class="thinborder">
	  		<font size="1"><b>PER SUBJECT TUITION FEE</b></font>
	  </td>
    </tr>
	<%}%>
    <tr> 
      <td height="22" class="thinborder"> <%=WI.getStrValue((String)vRetResult.elementAt(i + 2),(String)vRetResult.elementAt(i + 1)+":::","",WI.getStrValue((String)vRetResult.elementAt(i + 1),"--''--"))%> </td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder">&nbsp;
	  	<%if( ((String)vRetResult.elementAt(i + 6)).equals("1")){%> <img src="../../../images/tick.gif"><%}%>
	  </td>
	  
      <td class="thinborder"> 
	  	<%if( ((String)vRetResult.elementAt(i + 3)).equals("0")) {bolCCodeShoudNull = true;
		if(bolIsCPU) {
			if(((String)vRetResult.elementAt(i + 4)).indexOf("/") != -1)
				strReadOnly = " readonly ";
			else	
				strReadOnly = "";
		}
		
		if(bolSetXLS) {%>
			<%=(String)vRetResult.elementAt(i + 4)%>
		<%}else{%>
			<input name="tuition<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
				onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" value="<%=(String)vRetResult.elementAt(i + 4)%>"
				onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%> >
			<input type="hidden" name="tuition_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 4)%>">	
			<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 7)%>">	
		<%}%>
		
		
		<%i += 8;p = i;}else{%> &nbsp; <%}%> 
	  </td>
      <td class="thinborder"> <%p = 0;if(i < vRetResult.size() && ((String)vRetResult.elementAt(i + 3)).equals("1"))  {
	  	if( (bolCCodeShoudNull && vRetResult.elementAt(i + 1) == null) || !bolCCodeShoudNull){
			bolCCodeShoudNull = true;
			if(bolIsCPU) {
				if(((String)vRetResult.elementAt(i + 4)).indexOf("/") != -1)
					strReadOnly = " readonly ";
				else	
					strReadOnly = "";
			}
		%> 
		<%if(bolSetXLS) {%>
			<%=(String)vRetResult.elementAt(i + 4)%>
		<%}else{%>	
			<input name="tuition<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
				onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" value="<%=(String)vRetResult.elementAt(i + 4)%>" 		
				onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
			<input type="hidden" name="tuition_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 4)%>">	
			<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 7)%>">	
		<%}%>
				
		<%i += 8;p = i;}}if(i != p){p = i;%> &nbsp; <%}%> </td>
      <td class="thinborder"> <%p = 0;if(i < vRetResult.size() && ((String)vRetResult.elementAt(i + 3)).equals("2"))  {
	  	if( (bolCCodeShoudNull && vRetResult.elementAt(i + 1) == null) || !bolCCodeShoudNull){bolCCodeShoudNull = true;
			if(bolIsCPU) {
				if(((String)vRetResult.elementAt(i + 4)).indexOf("/") != -1)
					strReadOnly = " readonly ";
				else	
					strReadOnly = "";
			}
		%> 	
		<%if(bolSetXLS) {%>
			<%=(String)vRetResult.elementAt(i + 4)%>
		<%}else{%>	
			<input name="tuition<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
				onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" value="<%=(String)vRetResult.elementAt(i + 4)%>"
				onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
			<input type="hidden" name="tuition_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 4)%>"> 
			<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 7)%>">			
		<%}%>
		<%i += 8;p = i;}}if(i != p){p = i;%> &nbsp; <%}%> </td>
      <td class="thinborder"> <%p = 0;if(i < vRetResult.size() && ((String)vRetResult.elementAt(i + 3)).equals("3"))  {
	  	if( (bolCCodeShoudNull && vRetResult.elementAt(i + 1) == null) || !bolCCodeShoudNull){bolCCodeShoudNull = true;
			if(bolIsCPU) {
				if(((String)vRetResult.elementAt(i + 4)).indexOf("/") != -1)
					strReadOnly = " readonly ";
				else	
					strReadOnly = "";
			}
		%>
		<%if(bolSetXLS) {%>
			<%=(String)vRetResult.elementAt(i + 4)%>
		<%}else{%>	
				<input name="tuition<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
				onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" value="<%=(String)vRetResult.elementAt(i + 4)%>" 			
				onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'"  <%=strReadOnly%>>
			<input type="hidden" name="tuition_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 4)%>"> 
			<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 7)%>">	
		<%}%>		
		<%i += 8;p = i;}}if(i != p){p = i;%> &nbsp; <%}%> </td>
      <td class="thinborder"> <%p = 0;if(i < vRetResult.size() && ((String)vRetResult.elementAt(i + 3)).equals("4"))  {
	  	if( (bolCCodeShoudNull && vRetResult.elementAt(i + 1) == null) || !bolCCodeShoudNull){bolCCodeShoudNull = true;
			if(bolIsCPU) {
				if(((String)vRetResult.elementAt(i + 4)).indexOf("/") != -1)
					strReadOnly = " readonly ";
				else	
					strReadOnly = "";
			}
		%>
		<%if(bolSetXLS) {%>
			<%=(String)vRetResult.elementAt(i + 4)%>
		<%}else{%>	
			<input name="tuition<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
				onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" value="<%=(String)vRetResult.elementAt(i + 4)%>" 		
				onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
			<input type="hidden" name="tuition_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 4)%>"> 
			<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 7)%>">	
		<%}%>		
		<%i += 8;p = i;}}if(i != p){p = i;%> &nbsp; <%}%> </td>
      <td class="thinborder"> <%p = 0;if(i < vRetResult.size() && ((String)vRetResult.elementAt(i + 3)).equals("5"))  {
	  	if( (bolCCodeShoudNull && vRetResult.elementAt(i + 1) == null) || !bolCCodeShoudNull){bolCCodeShoudNull = true;
			if(bolIsCPU) {
				if(((String)vRetResult.elementAt(i + 4)).indexOf("/") != -1)
					strReadOnly = " readonly ";
				else	
					strReadOnly = "";
			}
		%> 
		<%if(bolSetXLS) {%>
			<%=(String)vRetResult.elementAt(i + 4)%>
		<%}else{%>	
			<input name="tuition<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
				onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" value="<%=(String)vRetResult.elementAt(i + 4)%>" 		
				onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
			<input type="hidden" name="tuition_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 4)%>"> 
			<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 7)%>">	
		<%}%>		
		<%i += 8;p = i;}}if(i != p){p = i;%> &nbsp; <%}%> </td>
      <td class="thinborder"> <%p = 0;if(i < vRetResult.size() && ((String)vRetResult.elementAt(i + 3)).equals("6"))  {
	  	if( (bolCCodeShoudNull && vRetResult.elementAt(i + 1) == null) || !bolCCodeShoudNull){bolCCodeShoudNull = true;
			if(bolIsCPU) {
				if(((String)vRetResult.elementAt(i + 4)).indexOf("/") != -1)
					strReadOnly = " readonly ";
				else	
					strReadOnly = "";
			}
		%> 
		<%if(bolSetXLS) {%>
			<%=(String)vRetResult.elementAt(i + 4)%>
		<%}else{%>	
			<input name="tuition<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
				onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'" value="<%=(String)vRetResult.elementAt(i + 4)%>" 
				onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
			<input type="hidden" name="tuition_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 4)%>"> 
			<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 7)%>">	
		<%}%>
		<%i += 8;p = i;}}if(i != p){p = i;%> &nbsp; <%}%> </td>
    </tr>
    <%}%>
  </table>
 <%//print if some subjects are excluded from tuition fee.
 if(vExemptedSub != null && vExemptedSub.size() > 0) {%>
<table bgcolor="#FFFFFF" width="100%"><tr><td><br></td></tr></table>	
  <table align="center" width="100%" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
    <tr bgcolor="#DDDDDD"> 
      <td align="center" height="22" colspan="2" class="thinborder"> <b><font size="1">LIST OF SUBJECT EXCLUDED 
        IN TUITION FEE</font></b> </td>
    </tr>
<%for(int i = 0; i <  vExemptedSub.size();){%>
   <tr> 
      <td height="22" class="thinborder"><%=(String)vExemptedSub.remove(0)%>::<%=(String)vExemptedSub.remove(0)%> (<%=(String)vExemptedSub.remove(0)%>)</td>
      <td class="thinborder"><%if(vExemptedSub.size() > 0){%>
	  <%=(String)vExemptedSub.remove(0)%>::<%=(String)vExemptedSub.remove(0)%> (<%=(String)vExemptedSub.remove(0)%>)
	  <%}else{%>&nbsp;<%}%></td>
    </tr>
<%}%>
  </table> 
 <%}// vExemptedSub != null
 }//only if vRetResult != null;%>
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
		eval("document.form_.tuition" + document.form_.focus_index.value +".focus()");
</script>

<input type="hidden" name="info_index" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
