<%@ page language="java" import="utility.*,java.util.Vector,health.CTPreEnrollment " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Patient Health Status..</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function ViewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
			"&table_list="+escape(tablelist)+
			"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
			"&opner_form_name=form_";
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch()
{
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.contact_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CancelClicked(){
	location = "./manage_ct_type.jsp";
}
function PageAction(strIndex,strAction){	
	document.form_.schedIndex.value = strIndex;
	document.form_.pageAction.value = strAction;
	document.form_.createConsecutive.value = strAction;		
	this.SubmitOnce('form_');
}
function ReloadPage(){
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#8C9AAA" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iTemp = 0;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinical Test",
								"manage_ct_type.jsp");
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
														"Health Monitoring","Clinical Test",request.getRemoteAddr(),
														"manage_ct_type.jsp");
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
}//end of authenticaion code.


	CTPreEnrollment CTPE = new CTPreEnrollment();
	Vector vRetResult = new Vector();
	Vector vTestInfo = new Vector();	
	vTestInfo = null;
	boolean bolIsEditErr = false;	
	
	if(!WI.fillTextValue("pageAction").equals("")){
		vTestInfo = CTPE.operateOnTestInfo(dbOP,request,Integer.parseInt(WI.fillTextValue("pageAction")));
		if((WI.fillTextValue("pageAction").equals("2") || WI.fillTextValue("pageAction").equals("1")) && vTestInfo != null)
			bolIsEditErr = true;						
		strErrMsg = CTPE.getErrMsg();
	}		
	
	vRetResult = CTPE.operateOnTestInfo(dbOP,request,4);
	if(vRetResult == null)	
		strErrMsg = CTPE.getErrMsg();

%>
<form method="post" name="form_" action="manage_ct_type.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="28" colspan="5" bgcolor="#697A8F" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          MANAGE CLINICAL TESTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr > 
      <td  >&nbsp;</td>
      <td >Test Type :</td>
      <td colspan="3" > <% if(vTestInfo != null && bolIsEditErr == false)
	  	 	strTemp = (String)vTestInfo.elementAt(7);
	  	 else  
	  		strTemp = WI.fillTextValue("test_type"); %> <select name="test_type">
          <option value="">Select Type</option>
          <%=dbOP.loadCombo("TEST_TYPE_INDEX","TEST_TYPE"," FROM HM_CT_TESTTYPE order by TEST_TYPE", strTemp, false)%> </select> <a href='javascript:ViewList("HM_CT_TESTTYPE","TEST_TYPE_INDEX","TEST_TYPE","TEST TYPE",
	    "HM_CT_TESTTYPE ","TEST_TYPE_INDEX", "","")'><img src="../../../images/update.gif" border="0"></a> 
        <font size="1">click to update list of test types</font></td>
    </tr>
    <tr > 
      <td width="1%"  >&nbsp;</td>
      <td width="24%" >Test Code : </td>
      <td colspan="3" > <% if(vTestInfo != null && bolIsEditErr == false)
	  		strTemp = (String)vTestInfo.elementAt(1);
	  	 else   
			strTemp = WI.getStrValue(WI.fillTextValue("test_code_1"),"");	  
	  %> <input type="text" name="test_code_1"  value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr > 
      <td height="25" >&nbsp;</td>
      <td height="25" >Duration :</td>
      <td height="25" colspan="3" > <%if(vTestInfo != null && bolIsEditErr == false)
	  		strTemp = (String)vTestInfo.elementAt(9);
	  	else     
	  		strTemp = WI.getStrValue(WI.fillTextValue("dur_in_min"),"");	  
	  %> <input name="dur_in_min" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
	    onKeyUp= 'AllowOnlyInteger("form_","dur_in_min")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","dur_in_min");style.backgroundColor="white"' ></td>
    </tr>
    <tr > 
      <td height="20" >&nbsp;</td>
      <td height="20" >Date :</td>
      <td colspan="3"> <% if(vTestInfo != null && bolIsEditErr == false)
	  		strTemp = (String)vTestInfo.elementAt(2);
	  	  else 
	   		strTemp = WI.getStrValue(WI.fillTextValue("test_date"),"");	  
	  %> <input name="test_date" type="text" class="textbox" size="10" maxlength="10" value="<%=strTemp%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.test_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr > 
      <td height="20" >&nbsp;</td>
      <td>Start Time :</td>
      <td colspan="3"> <select name="start_hr">
          <%if(vTestInfo != null && bolIsEditErr == false)
	  			strTemp = (String)vTestInfo.elementAt(3);
	  		else 
				strTemp = WI.fillTextValue("start_hr");
				
		iTemp = Integer.parseInt(WI.getStrValue(strTemp,"9"));
		for(int i = 1 ; i <= 12; ++i) {
		if (iTemp == i){%>
          <option value="<%=i%>" selected> 
          <%if(i < 10){%>
          0 
          <%}%>
          <%=i%></option>
          <%}else{%>
          <option value="<%=i%>"> 
          <%if(i < 10){%>
          0 
          <%}%>
          <%=i%></option>
          <%}}%>
        </select> <select name="start_min">
          <%if(vTestInfo != null && bolIsEditErr == false)
	  			strTemp = (String)vTestInfo.elementAt(4);
	  		else 
				strTemp = WI.fillTextValue("start_min");  	
	  	iTemp = Integer.parseInt(WI.getStrValue(strTemp,"0"));
		for(int i = 0 ; i<=55; i += 5) {
		if (iTemp == i){%>
          <option value="<%=i%>" selected> 
          <%if(i < 10){%>
          0 
          <%}%>
          <%=i%></option>
          <%}else{%>
          <option value="<%=i%>"> 
          <%if(i < 10){%>
          0 
          <%}%>
          <%=i%></option>
          <%}}%>
        </select> <select name="start_ampm">
          <%if(vTestInfo != null && bolIsEditErr == false){
	  			strTemp = (String)vTestInfo.elementAt(5);
				if(strTemp.equals(" AM"))
					strTemp = "0";
				else
					strTemp = "1";
			}
	  		else 		  
		  		strTemp = WI.fillTextValue("start_ampm");
		  if(strTemp.equals("1"))	{%>
          <option value="0">AM</option>
          <option value="1" selected >PM</option>
          <%}else{%>
          <option value="0" selected>AM</option>
          <option value="1">PM</option>
          <%}%>
        </select>
        (hour,min,AM/PM)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Venue :</td>
      <td colspan="3"> <select name="venue">
          <% if(vTestInfo != null && bolIsEditErr == false)
	  		strTemp = (String)vTestInfo.elementAt(8);
	  	else 
	  		strTemp = WI.fillTextValue("venue");%>
          <option value="">Select Venue</option>
          <%=dbOP.loadCombo("VENUE_INDEX","VENUE_NAME"," FROM HM_CT_VENUE", strTemp, false)%> </select> <a href='javascript:ViewList("HM_CT_VENUE","VENUE_INDEX","VENUE_NAME","VENUE",
	    "HM_CT_VENUE","VENUE_INDEX", "","")'><img src="../../../images/update.gif" border="0"></a> 
        <font size="1">click to update list of venues</font></td>
    </tr>
    <tr > 
      <td height="24" >&nbsp;</td>
      <td height="24" >Maximum Capacity : </td>
      <td height="24" colspan="3" > <%if(vTestInfo != null && bolIsEditErr == false)
	  		strTemp = (String)vTestInfo.elementAt(10);
	  	else 	  
	 		strTemp = WI.getStrValue(WI.fillTextValue("max_cap"),"");%> <input name="max_cap" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
        onKeyUp= 'AllowOnlyInteger("form_","max_cap")' onFocus="style.backgroundColor='#D3EBFF'"
		onBlur='AllowOnlyInteger("form_","max_cap");style.backgroundColor="white"'></td>
    </tr>
    <tr > 
      <td height="25" >&nbsp;</td>
      <td height="25" >Contact Person ID : <br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        OR</td>
      <td width="27%" height="25" > <%if(vTestInfo != null && bolIsEditErr == false)
	  		strTemp = WI.getStrValue((String)vTestInfo.elementAt(11));
	  	else   
	  		strTemp = WI.getStrValue(WI.fillTextValue("contact_id"),"");%> <input type="text" name="contact_id"  value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
      <td colspan="2" ><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" hspace="0" vspace="0" border="0"></a></td>
    </tr>
    <tr > 
      <td height="25" >&nbsp;</td>
      <td height="25" >Contact Person Name :</td>
      <td height="25" colspan="3" > 
	  <%if(vTestInfo != null && bolIsEditErr == false)
	  		strTemp = WI.getStrValue((String)vTestInfo.elementAt(6),"");			
	  	else
	  		strTemp = WI.getStrValue(WI.fillTextValue("contact_name"),"");			
		%>
        <input type="text" name="contact_name" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
	<%if(!((WI.fillTextValue("pageAction").equals("2") || WI.fillTextValue("pageAction").equals("3")) && (vTestInfo != null))){%>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="4" > 
	  <%if(WI.fillTextValue("createConsecutive").equals("1"))
			strTemp = "checked";  
	    else
	  		strTemp = "";
	  %> <input type="checkbox" name="createConsecutive" value="1" onClick="javascript:ReloadPage();" <%=strTemp%>>
        &nbsp; Check to create consecutive schedules</td>
    </tr>
    <%if(WI.fillTextValue("createConsecutive").equals("1")){%>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="4" >Number of consecutive schedules : 
        <select name="num_con_sched" onChange="javscript:ReloadPage();">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_con_sched"),"3"));
				for(int i = 2; i <=10 ; i++) {
					if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select></td>
    </tr>
	<%if(WI.fillTextValue("num_con_sched").length() > 0)
		iTemp = Integer.parseInt(WI.fillTextValue("num_con_sched"));	
	  else
	  	iTemp = 3;	
	for(int iLoop = 1; iLoop < iTemp ;iLoop++){%>   
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >Test Code <%=iLoop+1%> :</td>
      <td height="25" >
	  <%if(WI.fillTextValue("test_code_"+(iLoop+1)).length() > 0)
	  		strTemp = WI.fillTextValue("test_code_"+(iLoop+1));			
		else
			strTemp = "";		
	  %>	  
	  <input type="text" name="test_code_<%=iLoop+1%>"  value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
      <%if( iLoop+1 < iTemp){
	  	iLoop++;%>
	  	<td width="21%">Test Code <%=iLoop+1%> :</td>
      	<td width="27%" >
		<%if(WI.fillTextValue("test_code_"+(iLoop+1)).length() > 0)
	  		strTemp = WI.fillTextValue("test_code_"+(iLoop+1));
		  else
			strTemp = "";
	    %>
		<input type="text" name="test_code_<%=iLoop+1%>"  value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
	  <%}%>
    </tr>
	<%}}}
	else{%>
		<tr>
			<td>&nbsp;</td>
			<td><input type="hidden" name="createConsecutive" value=""></td>
        </tr>
	<%}%>
    <tr> 
      <td height="25" colspan="5" >&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="5" ><div align="center"> 
          <%if((WI.fillTextValue("pageAction").equals("2") || WI.fillTextValue("pageAction").equals("3")) && vTestInfo != null){%>
          <a href="javascript:PageAction(<%=WI.fillTextValue("schedIndex")%>,2);"><img src="../../../images/edit.gif" border="0"></a><font size="1">Click 
          to edit event </font> 
          <%}else{%>
          <a href="javascript:PageAction(0,1);"><img src="../../../images/save.gif" border="0"></a><font size="1">Click 
          to save entries </font> 
          <%}%>
          <a href="javascript:CancelClicked();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">Click 
          to cancel entries</font></div></td>
    </tr>
    <tr > 
      <td height="20" colspan="5" ><hr size="1"></td>
    </tr>
  </table>
   <% if(vRetResult != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="11%" height="35">&nbsp;&nbsp; Filter List</td>
      <td width="23%"><% strTemp = WI.getStrValue(WI.fillTextValue("test_date_fr"),"");%> From : <input name="test_date_fr" type="text" class="textbox" size="10" maxlength="10" value="<%=strTemp%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.test_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td width="23%"> To : 
        <% strTemp = WI.getStrValue(WI.fillTextValue("test_date_to"),"");	%> <input name="test_date_to" type="text" class="textbox" size="10" maxlength="10" value="<%=strTemp%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.test_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td width="43%"> <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif"  border="0"></a></td>
    </tr>
  </table>
   
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFF9F"> 
      <td height="27" colspan="8"><div align="center"><strong><font  size="1">LIST 
          OF TEST SUBTYPES </font></strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="25"><div align="center"><strong><font size="1">TEST TYPE</font></strong></div></td>
      <td width="15%"><div align="center"><strong><font size="1">TEST CODE</font></strong></div></td>
      <td width="12%"><div align="center"><strong><font size="1">DATE OF TEST</font></strong></div></td>
      <td width="18%"><div align="center"><strong><font size="1">TIME</font></strong></div></td>
      <td width="13%"><div align="center"><strong><font size="1">VENUE</font></strong></div></td>
      <td width="20%"><div align="center"><strong><font size="1">CONTACT PERSON</font></strong></div></td>
      <td colspan="2"><div align="center"><strong><font size="1">OPTIONS</font></strong></div></td>
    </tr>
	<% for(int iLoop = 0; iLoop < vRetResult.size(); iLoop+=11){%>
    <tr>
      <td height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(iLoop+7)%></font></div></td>
      <td height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(iLoop+1)%></font></div></td>
      <td height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(iLoop+2)%></font></div></td>  
      <td height="25"><div align="center"><font size="1">
	  <%=CommonUtil.formatMinute((String)vRetResult.elementAt(iLoop+3))+':'+
	     CommonUtil.formatMinute((String)vRetResult.elementAt(iLoop+4))+' '+
		 (String)vRetResult.elementAt(iLoop+5)+' '
	  %>	  
	  - <%=(String)vRetResult.elementAt(iLoop+10)%></font></div></td>	  
      <td height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(iLoop+8)%></font></strong></div></td>
      <td height="25"><div align="center"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(iLoop+9),WI.getStrValue((String)vRetResult.elementAt(iLoop+6),"&nbsp;"))%></font></div></td>
      <td width="6%" height="25"><div align="center"><a href="javascript:PageAction(<%=(String)vRetResult.elementAt(iLoop)%>,3);"><img border="0" src="../../../images/edit.gif" ></a></div></td>
      <td width="6%" height="25"><div align="right"><a href="javascript:PageAction(<%=(String)vRetResult.elementAt(iLoop)%>,0);"><img border="0" src="../../../images/delete.gif" ></a></div></td>
    </tr>
	<%}%>
  </table>
  <%}%>
  <table  width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr >
      <td height="18" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>  
  <input type="hidden" name="schedIndex" value="<%=WI.fillTextValue("schedIndex")%>">
  <input type="hidden" name="pageAction" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
