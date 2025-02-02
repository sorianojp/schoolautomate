<%@ page language="java" import="utility.*,enrollment.SubjectSectionCPU, java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vAllSubjectSchedule = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CLASS PROGRAMS","pick_sched.jsp");
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
														"Enrollment","CLASS PROGRAMS",request.getRemoteAddr(),
														"pick_sched.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
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
SubjectSectionCPU SSCPU= new SubjectSectionCPU();
String strSubSecIndex = null;
int iRedirect = -2;

if (WI.fillTextValue("s_code").length() > 0) {
	iRedirect = SSCPU.getRedirectFile(dbOP,WI.fillTextValue("s_code"));
	
	if (iRedirect == 1) { 
		dbOP.cleanUP();
		strTemp = "sched_edit.jsp?stub_code=" + WI.fillTextValue("s_code");
	%>
		<script>
		location = "<%=strTemp%>";
		</script>
	<%
	return;
	}else if (iRedirect == -1){
		strErrMsg = SSCPU.getErrMsg();

	}else if (iRedirect == 0) {
		strSubSecIndex = dbOP.mapOneToOther("subject", "sub_code",
										"'" + WI.fillTextValue("s_code") + "'",
										"sub_index", " and is_del = 0 ");
		if (strSubSecIndex != null) {
			vAllSubjectSchedule = SSCPU.getOfferingPerCollege(dbOP,request,null,
																strSubSecIndex);
			
			if (vAllSubjectSchedule == null || vAllSubjectSchedule.size() ==0) 
				strErrMsg =  SSCPU.getErrMsg();
		}
	}
}


%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Edit Class Schedule</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<style type="text/css">
	a:link{
		text-decoration:none
	}
	a:visited{
		text-decoration:none
	}	
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage(){
	document.form_.submit();
}

function EditRecord(strInfoIndex){

	var loadPg = "./sched_edit.jsp?stub_code="+strInfoIndex+"&opner_form_name=form_";
	var win=window.open(loadPg,"newWin",'dependent=yes,width=650,height=550,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>


<body bgcolor="#D2AE72" onLoad="javascript:document.form_.s_code.focus();">
<form name="form_" action="./pick_sched.jsp" method="post" >
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><strong><font color="#FFFFFF"> CLASS PROGRAM - SELECT OFFERING</font></strong></div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr> 
      <td height="25" colspan="5"><font size="3" color="#FF0000"><b>&nbsp;<%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td width="2%" height="25"></td>
      <td width="12%">Acad Year : </td>
      <td width="22%"> 
<%
	strTemp = WI.fillTextValue("sy_from");
	if (strTemp.length() != 4) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	
%> <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
   	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to')" value="<%=strTemp%>" size="4" maxlength="4">
        - 
      <%
	strTemp = WI.fillTextValue("sy_to");
	if (strTemp.length() != 4) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" class="textbox" readonly="yes"
	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	value="<%=strTemp%>" size="4" maxlength="4"></td>
      <%
	strTemp = WI.fillTextValue("semester");
	if (strTemp.length() == 0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
      <td width="7%">Term : </td>
      <td width="57%"><select name="semester">
	  <option value="1"> 1st Sem</option>
	  <%if(strTemp.equals("2")) {%>
	  <option value="2" selected> 2nd Sem</option>
	  <%}else{%>
	  <option value="2"> 2nd Sem</option>
	  <%}if (strTemp.equals("0")) {%>
	  <option value="0" selected> Summer</option>
	  <%}else{%>
	  <option value="0"> Summer</option>
	  <%}%>
	  </select>
	  &nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr> 
      <td height="25" width="3%"></td>
      <td width="24%"><strong>Stub Code/Subject Code: </strong></td>
      <td width="23%"> <input type="text" name="s_code" size="20" value="<%=WI.fillTextValue("s_code")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeyPress="if(event.keyCode==39 || event.keyCode==34) event.returnValue=false;">      </td>
      <td width="50%"><a href="javascript:ReloadPage()"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
  <%


	String strDay = "";
	String strRoom = "";
	String strCurrentCollege = null;
	String strPrevCollege = "";
	String strPrevSubj = "";
	String strCurrSubj = "";
	String strFacultyName = null;
	String strPrevSubSecIndex = "";
	String strCurrSubSecIndex = null;
	String strRoomNumber = null;
	String strUnit = null;
	String strSection = null;
	String strHourFrom = null;
	String strHourTo = null;
	String strFaculty = null;
	String strClassSize = null;
	String strLab = "";
	boolean bolDuplicate = false;
	String[] astrDay = {"S","M","T","W","TH","F","SAT","",""};
	
	float fTemp24HF = 0f;
	float fTemp24HT  = 0f;
	int[] iTimeDataFr = null;
	int[] iTimeDataTo = null;
	boolean bolIncremented = false;
	int iRollBack  = 0;
	
//	boolean bolForceBreak = false;

	if (vAllSubjectSchedule != null && vAllSubjectSchedule.size() > 0)  {
	

	for (int i = 0; i < vAllSubjectSchedule.size();){

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
<% 
	for (; i< vAllSubjectSchedule.size();) {
	strPrevSubj = (String)vAllSubjectSchedule.elementAt(i+4);
	bolIncremented = false;
	
    strCurrentCollege = (String)vAllSubjectSchedule.elementAt(i+1); // initial value;
	if (strCurrentCollege == null)
		strCurrentCollege = (String)vAllSubjectSchedule.elementAt(i+3);
	else
		strCurrentCollege += WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+3)," - ","","");

	if (i == 0 || !strCurrentCollege.equals(strPrevCollege)) {
		strPrevCollege = strCurrentCollege;
%> 
	<tr>
		<td height="25" colspan="9" class="thinborder"><strong>&nbsp;<%=strPrevCollege%></strong></td>
	</tr>
	<tr>
		<td height="25" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT</strong></font></div></td>
		<td class="thinborder"><div align="center"><font size="1"><strong>&nbsp;SECTION</strong></font></div></td>
	    <td class="thinborder"><div align="center"><font size="1"><strong>TIME </strong></font></div></td>
	    <td class="thinborder"><div align="center"><font size="1"><strong>DAY</strong></font></div></td>
	    <td class="thinborder"><div align="center"><font size="1"><strong>ROOM </strong></font></div></td>
	    <td class="thinborder"><div align="center"><font size="1"><strong>FACULTY</strong></font></div></td>
	    <td class="thinborder"><div align="center"><font size="1"><strong>ACAD UNITS </strong></font></div></td>
	    <td class="thinborder"> <div align="center"><font size="1"><strong>STUB CODE </strong></font></div></td>
	    <td class="thinborder"> <div align="center"><font size="1"><strong>CAP </strong></font></div></td>
	</tr>	
<%} // show college or depart offering

	bolDuplicate = false;

	
	strCurrSubSecIndex = (String)vAllSubjectSchedule.elementAt(i+6);
	strHourFrom= WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+8));
	strHourTo = WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+9)); 
	strRoomNumber = WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+15),"TBA");
	strSection = WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+7),"&nbsp;"); 
	strClassSize = WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+11),"--");

	if (((String)vAllSubjectSchedule.elementAt(i+16)).equals("1"))
		strLab = " Lab";
	else
		strLab ="";


	if ((String)vAllSubjectSchedule.elementAt(i+17) != null) 
		strFaculty = ((String)vAllSubjectSchedule.elementAt(i+18)).charAt(0) + ". " +
						(String)vAllSubjectSchedule.elementAt(i+20);
	else
		strFaculty = "c/o";
		
	if(((String)vAllSubjectSchedule.elementAt(i+16)).equals("0")){
		strUnit = WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+12),"--");
	}else{
		strUnit = WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+13),"--");
	}		
	
	if (strSection.length() > 20) 
		strSection = strSection.substring(0,20);
	
	if (strSection.equals("*"))
		strSection = "&nbsp;";
	
	if (strPrevSubSecIndex.equals(strCurrSubSecIndex))
		bolDuplicate = true;
		
	strDay="";
	
	fTemp24HF = 0f;
	fTemp24HT = 0f;	
	
	if (vAllSubjectSchedule.elementAt(i+8)!=null && vAllSubjectSchedule.elementAt(i+9) != null)
    {  	
    	fTemp24HF = Float.parseFloat((String)vAllSubjectSchedule.elementAt(i+8));
	    fTemp24HT = Float.parseFloat((String)vAllSubjectSchedule.elementAt(i+9));
	    
	    iTimeDataFr = comUtil.convert24HRTo12Hr(fTemp24HF);
		if (iTimeDataFr != null && (iTimeDataFr[2]  == 1) && iTimeDataFr[0] < 12)
			iTimeDataFr[0] +=12;
			
	    iTimeDataTo = comUtil.convert24HRTo12Hr(fTemp24HT);
		if (iTimeDataTo != null && (iTimeDataTo[2]  == 1) && iTimeDataTo[0] < 12)
			iTimeDataTo[0] +=12;
	} 	
	

	while ( i < vAllSubjectSchedule.size() && 
			strCurrSubSecIndex.equals((String)vAllSubjectSchedule.elementAt(i+6)) &&
			strHourFrom.equals(WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+8))) && 
			strHourTo.equals(WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+9))) &&
			strRoomNumber.equals(WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+15),"TBA"))) {

		strDay += astrDay[Integer.parseInt(WI.getStrValue((String)vAllSubjectSchedule.elementAt(i+10),"8"))];
		bolIncremented = true;
		i+=22;
	}
		strPrevSubSecIndex = strCurrSubSecIndex;
	// check before printing if it can still be accomodated to the number of rows per page

	strPrevSubj += strLab;
	
	if (strPrevSubj.length() > 13) 
		strPrevSubj = strPrevSubj.substring(0,13);
%> 
    <tr>
<% if (bolDuplicate){
	strTemp = "";
}else{
	strTemp = strPrevSubj;
} %>
      <td width="18%" height="22" class="thinborder">&nbsp;<%=strTemp%></td>
<% if (bolDuplicate){
	strTemp = "";
}else{
	strTemp = strSection;
} %>

      <td width="17%" height="22" class="thinborder">&nbsp;<%=strTemp%></td>
<%	if (fTemp24HF != 0f && fTemp24HT != 0f && iTimeDataFr != null && iTimeDataTo != null){
      strTemp = comUtil.formatMinute(Integer.toString(iTimeDataFr[0])) + 
				comUtil.formatMinute(Integer.toString(iTimeDataFr[1])) + "-" +
				comUtil.formatMinute(Integer.toString(iTimeDataTo[0])) + 
				comUtil.formatMinute(Integer.toString(iTimeDataTo[1]));
    }else{
		strTemp = "TBA";
		strDay = "TBA";
	} 
%>   
      <td width="10%" class="thinborder">&nbsp;<%=strTemp%></td>
      <td width="7%" class="thinborder">&nbsp;<%=strDay%></td>
	  <td width="9%" class="thinborder">&nbsp;<%=strRoomNumber%></td>  
      <td width="19%" class="thinborder">&nbsp;<%=strFaculty%></td>
<% if (bolDuplicate){
	strTemp = "";
}else{
	strTemp = strUnit;
} %>	  
      <td width="5%" class="thinborder">&nbsp;<%=strTemp%></td>
<%
 if (bolDuplicate)
	strTemp = "";
 else
	strTemp =  "<a href=\"javascript:EditRecord("+ strCurrSubSecIndex+")\"> " +  strCurrSubSecIndex + "</a>";  

%>
      <td width="8%" class="thinborder"><strong>&nbsp;<%=strTemp%></strong></td>
<%
 if (bolDuplicate)
	strTemp = "&nbsp;";
 else
	strTemp =  strClassSize;  

%>	  
      <td width="7%" class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
    </tr>
<%  
	if (!bolIncremented){
		System.out.println("Infinite Loop ::  Gen Sched Print : " + 
				WI.fillTextValue("sy_from") + " - " +  WI.fillTextValue("sy_to") +
				" : " + WI.fillTextValue("semester"));
		break; 
   	  }
	} // end inner for loop %>
  </table>
<% } // end page
} // end no result
 %>
 
<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
</table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
