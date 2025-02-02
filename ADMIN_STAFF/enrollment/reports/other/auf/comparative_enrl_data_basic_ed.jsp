<%@ page language="java" import="utility.*,java.util.Vector,java.text.*"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function Proceed(){
   document.form_.refresh_page.value="1";
   document.form_.submit();
}
function PrintPg(){
   if(!confirm("Click OK to print Page."))
		return;
		
	document.bgColor = "#FFFFFF";
	
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
								
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
				
	document.getElementById('myADTable3').deleteRow(0);
	
	document.getElementById('myADTable6').deleteRow(0);	
	document.getElementById('myADTable6').deleteRow(0);
	
	window.print();
}
function TogglePage(){
	document.form_.shift_page_course.value = "1";
	this.SubmitOnce("form_");
}
</script>
<style type="text/css">
TD.thinborderTOPLEFTBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
</style>
<body bgcolor="#D2AE72">
<%
	String strTemp = null;	
	String strErrMsg = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT","enrolment_data_per_college_basic.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> 
			<font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font>
		</p>
		<%return;
	}
	
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"Enrollment","REPORTS",request.getRemoteAddr(),"enrolment_data_per_college_basic.jsp");
					
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}

    //end of authenticaion code.
    Vector vRetResult =null;	
	Vector vSubTotal  =null;
	Vector vGradTotal= null;	
    enrollment.ReportEnrollmentAUF enrlReport = new enrollment.ReportEnrollmentAUF();   
       
	 int iElemCount = 0;
    if(WI.fillTextValue("refresh_page").equals("1")){
	  vRetResult = enrlReport.generateComparativeEnrlDataBasic(dbOP, request);
	  if(vRetResult == null)
		strErrMsg = enrlReport.getErrMsg();	
	else
		iElemCount = enrlReport.getElemCount();
    }   
	
    String[] astrSemester={"Summer","1st Sem.","2nd Sem."," 3rd Sem.","4th Sem."};
%>
<form action="./comparative_enrl_data_basic_ed.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
	<tr bgcolor="#A49A6A">
	  <td width="100%" height="25" colspan="4" bgcolor="#A49A6A">
	   <div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">
	   <strong>:::: ENROLLMENT DATA BASIC EDUCATIONREPORT PAGE::::</strong></font></div></td>
	</tr>
	<tr bgcolor="#FFFFFF">	
	  <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
	</tr>
</table>  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
<tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="18%">Previous SY-Term</td>
      <td colspan="2"> 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("prev_sy_from"));
%> <input name="prev_sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','prev_sy_from','prev_sy_to');">
        to 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("prev_sy_to"));
%> <input name="prev_sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>        
	&nbsp;
	<select name="prev_semester">
<%
	strTemp = WI.getStrValue(WI.fillTextValue("prev_semester"));
%>	<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select> 
		&nbsp; &nbsp;
		
		
	 <input name="prev_as_of_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("prev_as_of_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.prev_as_of_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>
		</td>      
    </tr>
	
	

<tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="18%">Current SY-Term</td>
      <td colspan="2"> 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>        
	&nbsp;
	<select name="semester">
<%
	strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
%>	<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select> 
		&nbsp; &nbsp;
		
	 <input name="as_of_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("as_of_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.as_of_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>
		</td>      
    </tr>

</tr>
<tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td colspan="2"><a href="javascript:Proceed();"><img src="../../../../../images/refresh.gif" border="0" align="absmiddle"></a></td>
</tr>
</table>   
<%if(vRetResult!=null && vRetResult.size()>0){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
      <tr>
        <td height="25">
  		  <div align="right"><a href="javascript:PrintPg();">
			  <img src="../../../../../images/print.gif" width="58" height="26" border="0"></a>
			  <font size="1">click to print entries</font>
  		  </div>
  	    </td>
      </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
	<tr>
		<td height="25" colspan="9" align="center">
		  <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
		  <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
		  <br><strong>Integrated School</strong><br><BR>
		  <strong>ENROLLMENT DATA</strong><BR>
		  AY <%=WI.fillTextValue("prev_sy_from")%> - <%=WI.fillTextValue("prev_sy_to")%> VS. AY 
		  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="myADTable5">
    <tr style="font-weight:bold">
	  <td height="26" class="thinborder" rowspan="3"><div align="center"></div></td>
	  <td width="15%" class="thinborder" height="20"><div align="center">AY <%=WI.fillTextValue("prev_sy_from")%>-<%=WI.fillTextValue("prev_sy_to")%></div></td>
	  <td class="thinborder" height="20"><div align="center">AY <%=WI.fillTextValue("prev_sy_from")%>-<%=WI.fillTextValue("prev_sy_to")%></div></td>
	  <td class="thinborder" align="center">AY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></td>
	  <td colspan="2" class="thinborder" align="center">Comparative Enrollment Data </td>
	  <td colspan="2" class="thinborder"><div align="center">Expected Enrollees</div></td>
	  </tr>
	<tr>
	   <td class="thinborder" height="20"><div align="center"><strong>(Total Enrollment)</strong></div>	   </td>
	   <td width="15%" class="thinborder" height="20"><div align="center"><strong>(as of <%=WI.formatDate(WI.fillTextValue("prev_as_of_date"), 6)%> )</strong></div>       </td>
	   <td width="15%" class="thinborder" align="center"><strong>(as of <%=WI.formatDate(WI.fillTextValue("as_of_date"), 6)%>)</strong></td>
	   <td width="8%" class="thinborder" align="center"><strong>C1</strong></td>
	   <td width="8%" class="thinborder" align="center"><strong>C2</strong></td>
	   <td width="8%" class="thinborder" align="center"><strong>E1</strong></td>
	   <td width="8%" class="thinborder" align="center"><strong>E2</strong></td>
	</tr>
	<tr style="font-weight:bold">
		<td class="thinborder" height="20">
		<div align="center"><strong>D1</strong></div>		</td>
		<td class="thinborder" height="20">
		<div align="center"><strong>D2</strong></div>		</td>	
	    <td class="thinborder">
		<div align="center"><strong>D3</strong></div>		</td>
	    <td class="thinborder" align="center">D3-D1</td>
	    <td class="thinborder" align="center">D3-D2</td>
	    <td class="thinborder" align="center">&nbsp;</td>
	    <td class="thinborder" align="center">&nbsp;</td>
	</tr>
    <% 
vGradTotal =(Vector)vRetResult.remove(0);	   
vSubTotal = (Vector)vRetResult.remove(0);	   
int iIndexOf = 0;
String strCurrEduLevel = null;
String strPrevEduLevel = "";

for(int i = 0 ; i< vRetResult.size();){

	for(; i< vRetResult.size(); i += iElemCount){
	
	strCurrEduLevel = (String)vRetResult.elementAt(i+1);
	if(!strPrevEduLevel.equals(strCurrEduLevel)){
		strPrevEduLevel = strCurrEduLevel;
		if(i > 0)
			break;
	}
	
	
    %>
	<tr>
		<td height="25" class="thinborder">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"0")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"0")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"0")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"0")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"0")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+9),"0")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"0")%></td>
	</tr>	
    <%}//end of vRetResult loop
	
	
	strErrMsg = (String)vRetResult.elementAt((i + 1) - iElemCount);
	%>      
	
	<tr>
		<td class="thinborder" height="25"><strong>SUB TOTAL</strong></td>
		<%
		strTemp = null;
		iIndexOf = vSubTotal.indexOf(strErrMsg+"_1");
		if(iIndexOf > -1)
			strTemp = (String)vSubTotal.elementAt(iIndexOf + 1);
		%>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue(strTemp,"0")%></strong></td>
		<%
		strTemp = null;
		iIndexOf = vSubTotal.indexOf(strErrMsg+"_2");
		if(iIndexOf > -1)
			strTemp = (String)vSubTotal.elementAt(iIndexOf + 1);
		%>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue(strTemp,"0")%></strong></td>		
		<%
		strTemp = null;
		iIndexOf = vSubTotal.indexOf(strErrMsg+"_3");
		if(iIndexOf > -1)
			strTemp = (String)vSubTotal.elementAt(iIndexOf + 1);
		%>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue(strTemp,"0")%></strong></td>
		<%
		strTemp = null;
		iIndexOf = vSubTotal.indexOf(strErrMsg+"_4");
		if(iIndexOf > -1)
			strTemp = (String)vSubTotal.elementAt(iIndexOf + 1);
		%>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue(strTemp,"0")%></strong></td>
		<%
		strTemp = null;
		iIndexOf = vSubTotal.indexOf(strErrMsg+"_5");
		if(iIndexOf > -1)
			strTemp = (String)vSubTotal.elementAt(iIndexOf + 1);
		%>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue(strTemp,"0")%></strong></td>
		<%
		strTemp = null;
		iIndexOf = vSubTotal.indexOf(strErrMsg+"_6");
		if(iIndexOf > -1)
			strTemp = (String)vSubTotal.elementAt(iIndexOf + 1);
		%>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue(strTemp,"0")%></strong></td>
		<%
		strTemp = null;
		iIndexOf = vSubTotal.indexOf(strErrMsg+"_7");
		if(iIndexOf > -1)
			strTemp = (String)vSubTotal.elementAt(iIndexOf + 1);
		%>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue(strTemp,"0")%></strong></td>
	</tr>
<%}//end outer loop%>
	 
	
    <tr>
		<td class="thinborder" height="25"><strong>GRAND TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue((String)vGradTotal.elementAt(0),"0")%></strong></td>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue((String)vGradTotal.elementAt(1),"0")%></strong></td>		
		<td class="thinborder" align="center"><strong><%=WI.getStrValue((String)vGradTotal.elementAt(2),"0")%></strong></td>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue((String)vGradTotal.elementAt(3),"0")%></strong></td>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue((String)vGradTotal.elementAt(4),"0")%></strong></td>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue((String)vGradTotal.elementAt(5),"0")%></strong></td>
		<td class="thinborder" align="center"><strong><%=WI.getStrValue((String)vGradTotal.elementAt(6),"0")%></strong></td>
	</tr>
</table>
<%}//end of vRetResult !=null && vRetResult.size()>0%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable6">
	<tr>
		<td height="25">&nbsp;</td>
	</tr>
	<tr bgcolor="#B8CDD1">
		<td height="25" bgcolor="#A49A6A">&nbsp;</td>
	</tr>
</table>
<input type="hidden" name="refresh_page"/>
<input type="hidden" name="print_page"/>
<input type="hidden" name="shift_page_course"/>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>