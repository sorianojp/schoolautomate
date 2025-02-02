<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
	TD{font-size: 11px;}
.style1 {font-weight: bold}

-->
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(){

	document.form_.submit();
	
}
function PageAction(strAction, strInfoIndex) {
	if (strAction == '0'){
		if (!confirm('Confirm Delete Record'))
			return;
	}

	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	
	document.form_.submit();
}
function PreparedToEdit(strInfoIndex) {
	document.form_.preparedToEdit.value = "1";
	document.form_.page_action.value = '';
	document.form_.info_index.value = strInfoIndex;
	
	document.form_.submit();
}

function ClearPage(){
	document.form_.preparedToEdit.value="";
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.clear_all.value = "1";
}

 
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.RLEInformation,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Reports-Others","rle_setting_batch.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
RLEInformation rleInfo = new RLEInformation();
Vector vRetResult  = null;
Vector vEditInfo   = null;

String strPageAction = WI.fillTextValue("page_action");
boolean bolClearAll = WI.fillTextValue("clear_all").equals("1");

if(strPageAction.length() > 0) {
	if(rleInfo.operateOnRLEBatchSchedule(dbOP, request, Integer.parseInt(strPageAction)) == null) 
		strErrMsg = rleInfo.getErrMsg();
	else {
		strPrepareToEdit = "0";
		if (strPageAction.equals("2")) 
			bolClearAll = true;
			
		strErrMsg = "Operation successful.";
	}
}

if(strPrepareToEdit.equals("1")) {
	vEditInfo = rleInfo.operateOnRLEBatchSchedule(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = rleInfo.getErrMsg();
}

vRetResult = rleInfo.operateOnRLEBatchSchedule(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = rleInfo.getErrMsg();
	


%>

<form name="form_" action="./rle_setting_batch.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        RLE SETTING ::::</strong></font></td>
    </tr>
    <tr>
      <td width="1%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold"><a href="./rle_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a>&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td height="32" >&nbsp;</td>
      <td width="8%"><strong>&nbsp;&nbsp;Batch</strong></td>
      <td width="15%" ><font size="1">
	  <% if(strPrepareToEdit.equals("1"))
	  		strTemp = "readonly"; 
		  else
		  	strTemp = "";
	  %> 
	  
        <input name="batch_no" type="text" class="textbox"  size="12"
				value="<%=WI.fillTextValue("batch_no")%>" <%=strTemp%>>
      </font></td>
      <td width="76%" >
	    <a href="javascript:ReloadPage()">
	  <img src="../../../../images/form_proceed.gif" border="0"> </a></td>
    </tr>
  </table>
<% if (WI.fillTextValue("batch_no").length() > 0) {%> 
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr>
      <td height="18" >&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="5" >&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25" >&nbsp;</td>
      <td width="8%"><strong>Subject</strong></td>
      <td width="21%" ><font size="1">
        <input type="text" name="scroll_sub" size="12" style="font-size:11px" class="textbox"
	  onKeyUp = "AutoScrollList('form_.scroll_sub','form_.sub_index',true);">
      (scroll) </font>	  </td>
      <td width="23%" ><font size="1">&nbsp;</font><strong> Display Order Number :</strong></td>
	  <% if (vEditInfo != null && vEditInfo.size() > 0) 
	  		strTemp = (String)vEditInfo.elementAt(9);
		else 
			strTemp = WI.fillTextValue("order_no");  

		if (bolClearAll)
			strTemp = "";	
	  %>
	  
      <td width="15%" ><select name="order_no">
    <% 
	  if(strTemp.length() == 0) 
	  	strTemp = "0";
	  int iOrderNo = Integer.parseInt(strTemp);
	  for(int i = 1; i < 21; ++i){
	  	if(iOrderNo == i)
			strTemp = " selected";
		else	
			strTemp = "";
		%>
        <option value="<%=i%>" <%=strTemp%>><%=i%></option>
        <%}%>
      </select></td>
      <td width="16%" >&nbsp;</td>
      <td width="15%" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
	  <% if (vEditInfo != null && vEditInfo.size() > 0) 
	  		strTemp = (String)vEditInfo.elementAt(2);
		else 
			strTemp = WI.fillTextValue("sub_index");  
			
		if (bolClearAll)
			strTemp = "";	
		%>
      <td colspan="6">
	  <select name="sub_index" style="font-family:Verdana, Arial, Helvetica, sans-serif;">
<!--	  	<option value=""> ..Select RLE Subject.. </option>   -->
        <%=dbOP.loadCombo("sub_index","sub_code + ' ::: ' + sub_name"," from subject where IS_DEL=0 "+
			" and exists (select * from curriculum join course_offered on  " + 
			" (curriculum.course_index = course_offered.course_index)  " + 
			" where curriculum.sub_index = subject.sub_index  " + 
			" and course_name like '%nursing%'  and curriculum.is_del = 0 " + 
			"  and curriculum.is_valid = 1  and course_offered.is_del =  0 " +
			" and course_offered.is_valid = 1)" + 
			" order by sub_code asc", strTemp, false)%>
      </select></td>
    </tr>
  </table>
  <table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr>
      <td height="18" >&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="16%"><strong>No of Hours / Wk</strong></td>
	  <% if (vEditInfo != null && vEditInfo.size() > 0) 
	  		strTemp = (String)vEditInfo.elementAt(6);
		else 
			strTemp = WI.fillTextValue("hours_per_week");  
		if (bolClearAll)
			strTemp = "";	
		%>	  
      <td valign="bottom"><input name="hours_per_week" type="text" class="textbox"  size="6"
				value="<%=WI.getStrValue(strTemp)%>"></td>
      <td width="11%"><strong>Total Hours </strong></td>
	  <% if (vEditInfo != null && vEditInfo.size() > 0) 
	  		strTemp = WI.getStrValue((String)vEditInfo.elementAt(10));
		else 
			strTemp = WI.fillTextValue("total_hours");  

		if (bolClearAll)
			strTemp = "";	
		%>		  
      <td width="56%" valign="bottom"><input name="total_hours" type="text" class="textbox"  size="6"
				value="<%=WI.getStrValue(strTemp)%>"></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="4" valign="bottom"><strong>RLE   
        FOCUS</strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
	  <% if (vEditInfo != null && vEditInfo.size() > 0) 
	  		strTemp = (String)vEditInfo.elementAt(5);
		else 
			strTemp = WI.fillTextValue("focus_");  
		if (bolClearAll)
			strTemp = "";	
			
		%>	  
      <td colspan="4" valign="top">
	  <textarea name="focus_" rows="3" cols="75" class="textbox" style="font-size:11px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr>
      <td height="18" >&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td width="15%">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="57%"><strong>Clinical Area </strong></td>
      <td colspan="2"><strong>No. of Wks </strong></td>
    </tr>
    <tr>
      <td >&nbsp;</td>
	  <% if (vEditInfo != null && vEditInfo.size() > 0) 
	  		strTemp = (String)vEditInfo.elementAt(7);
		else 
			strTemp = WI.fillTextValue("clinical_area");  
		if (bolClearAll)
			strTemp = "";	
			
		%>	  
      <td><textarea name="clinical_area" rows="10" cols="64" class="textbox" style="font-size:11px;"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
	  <% if (vEditInfo != null && vEditInfo.size() > 0) 
	  		strTemp = (String)vEditInfo.elementAt(8);
		else 
			strTemp = WI.fillTextValue("no_of_weeks");  

		if (bolClearAll)
			strTemp = "";	
		%>		
      <td width="10%">
	  	<textarea name="no_of_weeks" rows="10" cols="8" class="textbox" 
			style="font-size:11px; padding-left:5px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
      <td width="31%" height="20" align="center">
	  <table  width="96%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
        <tr>
          <td height="20" colspan="2" align="center" style="border:#000000 solid 1px 1px 1x 1px;"><span class="style1"><strong>Example Entry </strong></span></td>
        </tr>
        <tr>
          <td width="80%" height="30" style="border:#000000 solid 1px 1px 1x 1px;"><span class="style1">Clinical Area </span></td>
          <td width="20%" align="center" style="border:#000000 solid 1px 1px 1x 1px;"><span class="style1"> No. Wks </span></td>
        </tr>
        <tr>
          <td style="border:#000000 solid 1px 1px 1x 1px;"><font style="font-size:11px"> Skills Laboratory<br>
            CGHMC Operating Room<br>
            CGHMC Recovery Room<br>
            CGHMC Heart Institute <br>
            CGHMC Dialysis Unit <br>
          </font> </td>
          <td width="20%" align="center" style="border:#000000 solid 1px 1px 1x 1px;"><font class="style1">3<br>
            4<br>
            3<br>
            3<br>
            2</font></td>
        </tr>
      </table></td>
    </tr>
    
    
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3" valign="top"><p>&nbsp;</p>      </td>
    </tr>
    <tr>
      <td height="25" align="center">&nbsp;</td>
      <td colspan="3" align="center"><%if(iAccessLevel > 1){
	  		if (vEditInfo == null){ 
   	  %>   <input type="submit" name="1" value=" Save All" 
	  				style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1', '');">
		<%}else{%> 
          <input type="submit" name="2" value=" Edit Record " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('2', '');">
          <input type="submit" name="3" value=" Cancel  " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="ClearPage();">

		<%}%>  

          <%}%>
        &nbsp;&nbsp;</td>
    </tr>
    <tr>
      <td height="25" align="center">&nbsp;</td>
      <td colspan="3" align="center">&nbsp;</td>
    </tr>
  </table>
 
<% if (vRetResult != null ) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="myADTable4">
	<tr>
		<td height="25" colspan="7" align="center" class="thinborder"><strong>BATCH <%=WI.fillTextValue("batch_no")%> CLINICAL EXPERIENCE RECORD</strong></td>
	</tr>
	<tr>
	  <td width="3%" class="thinborder"> <strong>&nbsp;OR</strong> </td>
	  <td width="28%" class="thinborder"><strong>&nbsp;&nbsp;RLE Focus </strong></td>
      <td width="39%" class="thinborder"><strong>Clinical Area </strong></td>
      <td width="10%" class="thinborder"><div align="center"><strong>No. of <br>
      Weeks </strong></div></td>
      <td width="7%" class="thinborder"><strong>No. of Hours </strong></td>
      <td colspan="2" align="center" class="thinborder"><strong>Options</strong></td>
	</tr>
<% for (int i = 0; i < vRetResult.size() ;  i+= 11){%> 
	<tr>
	  <td class="thinborderLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
	  <td class="thinborderLEFT"><strong><%=(String)vRetResult.elementAt(i+3) + " :: " + 
	  					(String)vRetResult.elementAt(i+4)%></strong></td>
      <td class="thinborderLEFT">&nbsp;</td>
      <td align="center" class="thinborderLEFT">&nbsp;(<%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%> hrs/wk)</td>
      <td class="thinborderLEFT">&nbsp;</td>
      <td width="6%" rowspan="2" class="thinborder">
	  	<a href="javascript:PreparedToEdit('<%=(String)vRetResult.elementAt(i)%>')">
				<img src="../../../../images/edit.gif" border="0"></a>
	  </td>
	  <td width="7%" rowspan="2" class="thinborderBOTTOM">
		  <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>')">
		  	<img src="../../../../images/delete.gif" width="55" height="28" border="0"></a></td>
	</tr>
	<tr >
	  <td class="thinborder">&nbsp;</td>
	  <td valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7), "&nbsp;")%></td>
      <td align="center" valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8), "&nbsp;")%></td>
      <td align="center" valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"&nbsp;")%></td>
	</tr>
<%}%> 
 </table>
<%}%> 
  
<%//=dbOP.constructAutoScrollHiddenField()%>
<%} // show only if batch no exists%> 

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>




<input type="hidden" name="page_action">
<input type="hidden" name="preparedToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="clear_all">

<!-- add in pages with subject scroll -->





</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
