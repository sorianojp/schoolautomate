<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder{
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

</style>
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function ReloadPage()
{
	document.form_.proceed_clicked.value = "1";
	this.SubmitOnce('form_');
}
function OpenSearch()
{
	var pgLoc = "../../../search/srch_stud_temp.jsp?opner_info=form_.temp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vExamResults  = null;
	Vector vApplicantData = null;
	String strErrMsg = null;
	String strTemp = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";

//add security here.
	try
	{
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
//authenticate this user.

	ApplicationMgmt appMgmt = new ApplicationMgmt();
	
		//view exams 
	if (WI.fillTextValue("proceed_clicked").equals("1")){
		vApplicantData = appMgmt.operateOnApplicantStatus(dbOP, request, 4);
		if (vApplicantData == null || vApplicantData.size() == 0)
			strErrMsg = appMgmt.getErrMsg();
		else
		{
			vExamResults = appMgmt.operateOnApplicantStatus(dbOP, request, 2);
			if (vExamResults == null || vExamResults.size() == 0)
				strErrMsg = appMgmt.getErrMsg();
		}	
	}
	
%>
<form name="form_" method="post" action="./applicant_sched_view.jsp">
<input name="temp_id" type="hidden" class="textbox" value="<%=WI.fillTextValue("temp_id")%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td width="91%" height="25" colspan="8" bgcolor="#47768F"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">:::: 
      APPLICANT STATUS VIEWING::::</font></strong></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  
  	<tr> 
  		<td height="25" colspan="4"><font size="3"><strong>&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
  	</tr>
  	<tr> 
  		<td width=5%>&nbsp;</td>
  		<td width="17%">School Year/ Term</td>
  		<td>
  		<% strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); 
		%>
  		<input name="sy_from" type="text" class="textbox" size="4" maxlength="4"  value="<%=strTemp%>" 
		onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
  		to
  		<%  strTemp = WI.fillTextValue("sy_to");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); 
		%>
  		<input name="sy_to" type="text" class="textbox" size="4" maxlength="4" 
		value="<%=strTemp%>" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
  		<select name="semester">
  		<% strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		if(strTemp.compareTo("0") ==0){%>
  			<option value="0" selected>Summer</option>
  		<%}else{%>
  			<option value="0">Summer</option>
  		<%}if(strTemp.compareTo("1") ==0){%>
  			<option value="1" selected>1st Sem</option>
  		<%}else{%>
  			<option value="1">1st Sem</option>
  		<%}if(strTemp.compareTo("2") == 0){%>
  			<option value="2" selected=>2nd Sem</option>
  		<%}else{%>
  			<option value="2">2nd Sem</option>
  		<%}
		if (!strSchCode.startsWith("CPU")) { 
		  if(strTemp.compareTo("3") == 0){%>
  			<option value="3" selected>3rd Sem</option>
  		<%}else{%>
  			<option value="3">3rd Sem</option>
  		<%}
		}%>
 		</select>	  </td>
	    <td>
		<a href="javascript:ReloadPage()">
			<img src="../../../../images/refresh.gif" width="71" height="23" border=0>
		</a>
		
		</td>
  	</tr>
  	<tr>
  		<td height="2" colspan="4">&nbsp;</td>
	</tr>
  	<tr>
  		<td>&nbsp;</td>
  		<td>&nbsp;</td>
  		<td width= "30%">		</td>
  		<td width = 48%><a href="javascript:OpenSearch();"></a></td>
	</tr>
  </table>
  <%  if (vApplicantData!=null){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
   <tr>
   <td height="2">&nbsp;</td>
   <td>&nbsp;</td>
   <td>&nbsp;</td>
   </tr>
   <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2">Applicant Name : <strong><%=WI.formatName((String)vApplicantData.elementAt(0)+" ", (String)vApplicantData.elementAt(1), (String)vApplicantData.elementAt(2),7)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Date Applied : <strong><%=((String)vApplicantData.elementAt(3))%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%	  
	  strTemp = WI.getStrValue((String)vApplicantData.elementAt(5),"/","");
	  strTemp += WI.getStrValue((String)vApplicantData.elementAt(4),"");	  
	  %>	  
      <td height="25" colspan="2">Course/Major Applied : <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%String [] strAppStat = {"Denied", "Approved", "Under further evaluation"}; %>
      <td height="25">Current Application Status : <strong><%if((String)vApplicantData.elementAt(6)!= null){%>
	  											           <%=strAppStat[Integer.parseInt((String)vApplicantData.elementAt(6))]%>
														   <%}%></strong></td>
      <td>Status Updated : <strong><%if((String)vApplicantData.elementAt(7)!= null){%>
	  							   <%=((String)vApplicantData.elementAt(7))%>
								   <%}%></strong></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}
  if (vExamResults !=null)
  {
  %>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="11%" height="25" class="thinborder"><div align="center"><strong><font size="1"> 
          EXAM</font></strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong><font size="1">SCHEDULE CODE</font></strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong><font size="1">EXAM DATE</font></strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong><font size="1">START TIME</font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">DUR<br>
        (mins)</font></strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong><font size="1">VENUE</font></strong></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong><font size="1">CONTACT PERSON/INFO</font></strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong><font size="1">SCORE</font></strong></div></td>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">REMARKS</font></strong></td>
    </tr>
 <%   
 String [] astrConvTime={" AM"," PM"};
 for (int i = 0;i<vExamResults.size();){ %>
      <tr> 
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i)%></font></div></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i+1)%></font></div></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i+2)%></font></div></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=CommonUtil.formatMinute((String)vExamResults.elementAt(i+3))+':'+
	  CommonUtil.formatMinute((String)vExamResults.elementAt(i+4))+astrConvTime[Integer.parseInt((String)vExamResults.elementAt(i + 5))]%></font></div></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i+6)%></font></div></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i+7)%></font></div></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i+8)%>
      <br><font color="#0000FF"><%=(String)vExamResults.elementAt(i+9)%></font></font></div></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i+10)%></font></div></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i+11)%></font></div></td>
    </tr>
   	<% i = i + 13;
   	} //for (int i = 0;i<vExamResults.size();)%>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2" >&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" bgcolor="#47768F">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="proceed_clicked" value="">
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>