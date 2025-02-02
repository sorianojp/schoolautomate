<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(){
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}

function PrintPg()
{
	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	
	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	
	document.getElementById("myADTable3").deleteRow(2);
	
	document.getElementById("myADTable4").deleteRow(0);
	document.getElementById("myADTable4").deleteRow(0);
	document.getElementById("myADTable4").deleteRow(0);

	window.print();
}
function focusID() {
	document.form_.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS",request.getRemoteAddr(),
														null);
												
											
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = new Vector();
Vector vStudDetail= new Vector();


ReportEnrollment reportEnrl= new ReportEnrollment();


if(WI.fillTextValue("reloadPage").length() > 0)
{
	//vRetResult = reportEnrl.getStudScheduleDetail(dbOP, request);
	
	String strSQLQuery = null;
	java.sql.ResultSet rs = null;
	
	String strSYFrom = WI.fillTextValue("sy_from");
	String strSemester = WI.fillTextValue("offering_sem");
	if(strSYFrom.length() == 0 || strSemester.length() == 0) 
		strErrMsg = "Please provide SY-Term.";
	else{
		String strIDNumber = WI.fillTextValue("stud_id");
		if(strIDNumber.length() == 0) 
			strErrMsg = "Please provide student id number.";
		else{
			String strUserIndex = dbOP.mapUIDToUIndex(strIDNumber);
			if(strUserIndex == null)
				strErrMsg = "User id does not exist.";
			else{
				strIDNumber = "'" + ConversionTable.replaceString(strIDNumber, "'", "''") + "'";
				String strSection = "";				
				
				strSQLQuery = "select distinct user_table.user_index,fname,mname,lname, "+
						" course_offered.course_code,major.course_code,year_level"+					
						" from STUD_CURRICULUM_HIST "+
						" join user_table on (STUD_CURRICULUM_HIST.user_index=user_table.user_index) "+
						" left join course_offered on (STUD_CURRICULUM_HIST.course_index=course_offered.course_index) "+
						" left join major on (STUD_CURRICULUM_HIST.major_index=major.major_index) "+
						" where STUD_CURRICULUM_HIST.is_valid=1 and STUD_CURRICULUM_HIST.sy_from=" + strSYFrom + 
						" and semester=" + strSemester + 
						" and id_number=" + strIDNumber + 
						" and user_table.is_valid=1";
				rs = dbOP.executeQuery(strSQLQuery);
				if (rs.next()) {
					vStudDetail.addElement(rs.getString(1));//[0]				
					vStudDetail.addElement(WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4));//[1]
					if (rs.getString(6) != null)
						vStudDetail.addElement(rs.getString(5) + "/" + rs.getString(6));//[2]
					else
						vStudDetail.addElement(rs.getString(5));
					vStudDetail.addElement(rs.getString(7));//[3]				
				}
				rs.close();
				if (vStudDetail.size() == 0) 
					strErrMsg = "Student enrollment information not found.";
				else{				
					strSQLQuery = 
						" select WEEK_DAY,HOUR_FROM,MINUTE_FROM,AMPM_FROM,HOUR_TO,MINUTE_TO,AMPM_TO,ROOM_NUMBER, "+ 
								" sub_code, sub_name,section, E_ROOM_ASSIGN.SUB_SEC_INDEX, HOUR_FROM_24, HOUR_TO_24 "+
								" from E_ROOM_ASSIGN  "+
								" left join e_room_detail on (e_room_assign.room_index=e_room_detail.room_index) "+ 
								" join e_sub_section on (e_sub_section.sub_sec_index=e_room_assign.sub_sec_index) "+
								" join subject on (subject.SUB_INDEX = E_SUB_SECTION.SUB_INDEX) "+
								" join ENRL_FINAL_CUR_LIST on (ENRL_FINAL_CUR_LIST.SUB_SEC_INDEX = E_SUB_SECTION.SUB_SEC_INDEX) "+  
								" where E_ROOM_ASSIGN.is_del=0  "+
								" and E_ROOM_ASSIGN.is_valid=1  "+
								" and ENRL_FINAL_CUR_LIST.USER_INDEX =  "+strUserIndex+
								" and SY_FROM = "+strSYFrom+
								" and CURRENT_SEMESTER = "+strSemester+
								" order by hour_from_24,week_day asc ";
					rs = dbOP.executeQuery(strSQLQuery);
					while(rs.next()) {
						vRetResult.addElement(rs.getString(1));//[0]WEEK_DAY
						vRetResult.addElement(rs.getString(2));//[1]HOUR_FROM
						strSQLQuery = rs.getString(3);
						if(strSQLQuery.equals("0"))
							strSQLQuery += "0";
						vRetResult.addElement(strSQLQuery);//[2]MINUTE_FROM
						vRetResult.addElement(rs.getString(4));//[3]AMPM_FROM
						vRetResult.addElement(rs.getString(5));//[4]HOUR_TO
						strSQLQuery = rs.getString(6);
						if(strSQLQuery.equals("0"))
							strSQLQuery += "0";
						vRetResult.addElement(strSQLQuery);//[5]MINUTE_TO
						vRetResult.addElement(rs.getString(7));//[6]AMPM_TO
						vRetResult.addElement(rs.getString(8));//[7]ROOM_NUMBER
						vRetResult.addElement(rs.getString(9));//[8]sub_code
						vRetResult.addElement(rs.getString(10));//[9]sub_name
						vRetResult.addElement(rs.getString(11));//[10]section
						vRetResult.addElement(rs.getString(12));//[11]SUB_SEC_INDEX
						vRetResult.addElement(null);//[12]faculty name
						vRetResult.addElement(rs.getString(13));//[13]HOUR_FROM_24
						vRetResult.addElement(rs.getString(14));//[14]HOUR_TO_24
						vRetResult.addElement(null);//[15]				
		
						if(strSection.indexOf(rs.getString(11)) == -1) {
							if(strSection.length() == 0)
								strSection = rs.getString(11);
							else
								strSection += ", "+rs.getString(11);
						}		
		
					}rs.close();
		
					if(vRetResult.size() == 0) 
						strErrMsg = "Enrolled subject detail not found.";
					else{
						int iFormat = Integer.parseInt(WI.getStrValue(WI.fillTextValue("faculty_name_format"),"4"));
		
						strSQLQuery = 
								" select fname, mname, lname "+
										" from FACULTY_LOAD "+
										" join USER_TABLE on (USER_TABLE.USER_INDEX = FACULTY_LOAD.USER_INDEX) "+
										" where FACULTY_LOAD.IS_VALID= 1 "+
										" and SUB_SEC_INDEX = ?";
						java.sql.PreparedStatement pstmtSelectFaculty = dbOP.getPreparedStatement(strSQLQuery);
						for(int i =0; i < vRetResult.size(); i+=16) {
							strSQLQuery = null;
							
							pstmtSelectFaculty.setString(1, (String)vRetResult.elementAt(i+11));
							rs = pstmtSelectFaculty.executeQuery();
							while(rs.next()) {
								
								if(strSQLQuery == null)
									strSQLQuery = WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), iFormat);
								else
									strSQLQuery +="<br>" +WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), iFormat);
							}rs.close();
							
							vRetResult.setElementAt(strSQLQuery, i+12);
						}
						vStudDetail.addElement(strSection);
						
					}				
				}			
			}	
		}
	}	
	
}
dbOP.cleanUP();

if(strErrMsg == null) strErrMsg = "";
%>
<form action="./student_sched_plotting.jsp" method="post" name="form_">

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" size=""><strong>::::
          STUDENT'S SCHEDULE PAGE ::::</strong></font></strong></font></div></td>
    </tr>
  </table>


  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong> </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">School Year : </td>
      <td> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td colspan="3">Term :
        <select name="offering_sem">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
    </tr>    
    
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student ID : </td>
      <td width="20%" height="25"><input name="stud_id" type="text"  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="7%" height="25"><input type="image" src="../../../images/form_proceed.gif"></td>
      <td width="51%">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>
	  </td>
    </tr>
	 <tr>
    <td colspan="6" height="10"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudDetail != null && vStudDetail.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%" height="25">Student Name : </td>
      <td width="37%" height="25"><strong><%=(String)vStudDetail.elementAt(1)%></strong></td>
      <td width="45%" height="25">Year : <strong><%=WI.getStrValue(vStudDetail.elementAt(3),"N/A")%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major : </td>
      <td height="25"><strong><%=(String)vStudDetail.elementAt(2)%></strong></td>
      <td>Section : <%=WI.getStrValue(vStudDetail.elementAt(4),"N/A")%></td>
    </tr>
    <tr>
      <td height="25" align="right" colspan="4"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
      to print schedule</font></td>
    </tr>
  </table>

<table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="14%" align="center"><strong>MON</strong></td>
		<td width="14%" align="center"><strong>TUE</strong></td>
		<td width="14%" align="center"><strong>WED</strong></td>
		<td width="14%" align="center"><strong>THURS</strong></td>
		<td width="14%" align="center"><strong>FRI</strong></td>
		<td width="14%" height="25" align="center"><strong>SAT</strong></td>
		<td align="center"><strong>SUN</strong></td>
	</tr>
<%

Vector vTime = new Vector();
vTime.addElement("7.0");
vTime.addElement("7.5");
vTime.addElement("8.0");
vTime.addElement("8.5");
vTime.addElement("9.0");
vTime.addElement("9.5");
vTime.addElement("10.0");
vTime.addElement("10.5");
vTime.addElement("11.0");
vTime.addElement("11.5");
vTime.addElement("12.0");
vTime.addElement("12.5");
vTime.addElement("13.0");
vTime.addElement("13.5");
vTime.addElement("14.0");
vTime.addElement("14.5");
vTime.addElement("15.0");
vTime.addElement("15.5");
vTime.addElement("16.0");
vTime.addElement("16.5");
vTime.addElement("17.0");
vTime.addElement("17.5");
vTime.addElement("18.0");
vTime.addElement("18.5");
vTime.addElement("19.0");
vTime.addElement("19.5");
vTime.addElement("20.0");
vTime.addElement("20.5");
vTime.addElement("21.0");
vTime.addElement("21.5");


int iRowSpan0 = 0;
int iRowSpan1 = 0;
int iRowSpan2 = 0;
int iRowSpan3 = 0;
int iRowSpan4 = 0;
int iRowSpan5 = 0;
int iRowSpan6 = 0;


String[] convertAMPM={" am"," pm"};
int iRowSpan = 0;
int k = 0;
boolean bolShowTD = false;
for(int i = 0; i < vTime.size(); i++){
	//strTemp = (String)vTime.elementAt(i)+":"+(String)vTime.elementAt(i+1)+convertAMPM[Integer.parseInt((String)vTime.elementAt(i+2))] + " - "+
		//(String)vTime.elementAt(i+3)+":"+(String)vTime.elementAt(i+4)+convertAMPM[Integer.parseInt((String)vTime.elementAt(i+5))];		
	
%>
	<tr>
<%	
		iRowSpan = 0;
		bolShowTD = false;
		strTemp = "";
		for(k = 0; k < vRetResult.size(); k+=16){		
			if(  !WI.getStrValue((String)vRetResult.elementAt(k)).equals("1") )
				continue;				
			if( !((String)vTime.elementAt(i)).equals((String)vRetResult.elementAt(k+13)) )
				continue;
			bolShowTD = true;
			if(strTemp.length() > 0) 
				strTemp += "<br>";				
			iRowSpan1 = (int)(Double.parseDouble((String)vRetResult.elementAt(k+14)) - Double.parseDouble((String)vRetResult.elementAt(k+13))) * 2;		
			iRowSpan = iRowSpan1;			
			strTemp += WI.getStrValue(vRetResult.elementAt(k+8),"<br>","")+
				WI.getStrValue(vRetResult.elementAt(k+7),"<br>","")+
				(String)vRetResult.elementAt(k+1)+":"+(String)vRetResult.elementAt(k+2)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+3))]+
					" to "+(String)vRetResult.elementAt(k+4)+":"+(String)vRetResult.elementAt(k+5)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+6))]+
				"<br>"+WI.getStrValue(vRetResult.elementAt(k+12),"");
				
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);	
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);		
				k-=16;	
		}
if(bolShowTD || iRowSpan1 == 0){
%>	
		<td align="center" rowspan="<%=iRowSpan%>"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>

<%	
	
}
if(iRowSpan1 > 0)
	iRowSpan1--;
		
		iRowSpan = 0;
		bolShowTD = false;
		strTemp = "";		
		for(k = 0; k < vRetResult.size(); k+=16){		
			if(  !WI.getStrValue((String)vRetResult.elementAt(k)).equals("2") )
				continue;		
			
			if( !((String)vTime.elementAt(i)).equals((String)vRetResult.elementAt(k+13)) )
				continue;
			bolShowTD = true;
			if(strTemp.length() > 0) 
				strTemp += "<br>";				
			iRowSpan2 = (int)(Double.parseDouble((String)vRetResult.elementAt(k+14)) - Double.parseDouble((String)vRetResult.elementAt(k+13))) * 2;					
			iRowSpan = iRowSpan2;
			strTemp += WI.getStrValue(vRetResult.elementAt(k+8),"<br>","")+
				WI.getStrValue(vRetResult.elementAt(k+7),"<br>","")+
				(String)vRetResult.elementAt(k+1)+":"+(String)vRetResult.elementAt(k+2)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+3))]+
					" to "+(String)vRetResult.elementAt(k+4)+":"+(String)vRetResult.elementAt(k+5)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+6))];
				
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);	
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);		
				k-=16;	
		}
if(iRowSpan2 == 0 ||bolShowTD){
%>			
	
		<td align="center" rowspan="<%=iRowSpan%>"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
<%	
}
if(iRowSpan2 > 0)
	iRowSpan2--;
	
		bolShowTD = false;
		iRowSpan = 0;
		strTemp = "";		
		for(k = 0; k < vRetResult.size(); k+=16){		
			if(  !WI.getStrValue((String)vRetResult.elementAt(k)).equals("3") )
				continue;				
			if( !((String)vTime.elementAt(i)).equals((String)vRetResult.elementAt(k+13)) )
				continue;
			bolShowTD = true;
			if(strTemp.length() > 0) 
				strTemp += "<br>";				
			iRowSpan3 = (int)(Double.parseDouble((String)vRetResult.elementAt(k+14)) - Double.parseDouble((String)vRetResult.elementAt(k+13))) * 2;			
			iRowSpan = iRowSpan3;
			strTemp += WI.getStrValue(vRetResult.elementAt(k+8),"<br>","")+
				WI.getStrValue(vRetResult.elementAt(k+7),"<br>","")+
				(String)vRetResult.elementAt(k+1)+":"+(String)vRetResult.elementAt(k+2)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+3))]+
					" to "+(String)vRetResult.elementAt(k+4)+":"+(String)vRetResult.elementAt(k+5)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+6))];
				
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);	
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);		
				k-=16;	
		}
if(bolShowTD || iRowSpan3 == 0){
	
%>	
		<td align="center" rowspan="<%=iRowSpan%>"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
<%
}
if(iRowSpan3 > 0)
	iRowSpan3--;
		
		bolShowTD = false;
		iRowSpan = 0;
		strTemp = "";		
		for(k = 0; k < vRetResult.size(); k+=16){		
			if(  !WI.getStrValue((String)vRetResult.elementAt(k)).equals("4") )
				continue;				
			if( !((String)vTime.elementAt(i)).equals((String)vRetResult.elementAt(k+13)) )
				continue;
			bolShowTD = true;
			if(strTemp.length() > 0) 
				strTemp += "<br>";				
			iRowSpan4 = (int)(Double.parseDouble((String)vRetResult.elementAt(k+14)) - Double.parseDouble((String)vRetResult.elementAt(k+13))) * 2;					
			iRowSpan = iRowSpan4;
			strTemp += WI.getStrValue(vRetResult.elementAt(k+8),"<br>","")+
				WI.getStrValue(vRetResult.elementAt(k+7),"<br>","")+
				(String)vRetResult.elementAt(k+1)+":"+(String)vRetResult.elementAt(k+2)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+3))]+
					" to "+(String)vRetResult.elementAt(k+4)+":"+(String)vRetResult.elementAt(k+5)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+6))];
				
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);	
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);		
				k-=16;	
		}
if(bolShowTD || iRowSpan4 == 0){
	
%>	
		<td align="center" rowspan="<%=iRowSpan%>"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
<%		
}	
if(iRowSpan4 > 0)
	iRowSpan4--;
		
		bolShowTD = false;
		iRowSpan = 0;
		strTemp = "";		
		for(k = 0; k < vRetResult.size(); k+=16){		
			if(  !WI.getStrValue((String)vRetResult.elementAt(k)).equals("5") )
				continue;				
			if( !((String)vTime.elementAt(i)).equals((String)vRetResult.elementAt(k+13)) )
				continue;
			bolShowTD = true; 
			if(strTemp.length() > 0) 
				strTemp += "<br>";				
			iRowSpan5 = (int)(Double.parseDouble((String)vRetResult.elementAt(k+14)) - Double.parseDouble((String)vRetResult.elementAt(k+13))) * 2;					
			iRowSpan = iRowSpan5;
			strTemp += WI.getStrValue(vRetResult.elementAt(k+8),"<br>","")+
				WI.getStrValue(vRetResult.elementAt(k+7),"<br>","")+
				(String)vRetResult.elementAt(k+1)+":"+(String)vRetResult.elementAt(k+2)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+3))]+
					" to "+(String)vRetResult.elementAt(k+4)+":"+(String)vRetResult.elementAt(k+5)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+6))];
				
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);	
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);		
				k-=16;	
		}
if(iRowSpan5 == 0 || bolShowTD){
	
%>	
		<td align="center" rowspan="<%=iRowSpan%>"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
<%	
}
if(iRowSpan5 > 0)
	iRowSpan5--;
		
		iRowSpan = 0;
		bolShowTD = false;
		strTemp = "";		
		for(k = 0; k < vRetResult.size(); k+=16){		
			if(  !WI.getStrValue((String)vRetResult.elementAt(k)).equals("6") )
				continue;				
			if( !((String)vTime.elementAt(i)).equals((String)vRetResult.elementAt(k+13)) )
				continue;
			if(strTemp.length() > 0) 
				strTemp += "<br>";	
			bolShowTD = true; 			
			iRowSpan6 = (int)(Double.parseDouble((String)vRetResult.elementAt(k+14)) - Double.parseDouble((String)vRetResult.elementAt(k+13))) * 2;					
			iRowSpan = iRowSpan6;
			strTemp += WI.getStrValue(vRetResult.elementAt(k+8),"<br>","")+
				WI.getStrValue(vRetResult.elementAt(k+7),"<br>","")+
				(String)vRetResult.elementAt(k+1)+":"+(String)vRetResult.elementAt(k+2)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+3))]+
					" to "+(String)vRetResult.elementAt(k+4)+":"+(String)vRetResult.elementAt(k+5)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+6))];
				
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);	
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);		
				k-=16;	
		}
if(iRowSpan6 == 0 || iRowSpan6 > 0){
	
%>	
		<td align="center" rowspan="<%=iRowSpan%>"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
<%	
}	
if(iRowSpan6 > 0)
	iRowSpan6--;
		
		bolShowTD = false;
		iRowSpan = 0;
		strTemp = "";		
		for(k = 0; k < vRetResult.size(); k+=16){		
			if(  !WI.getStrValue((String)vRetResult.elementAt(k)).equals("0") )
				continue;				
			if( !((String)vTime.elementAt(i)).equals((String)vRetResult.elementAt(k+13)) )
				continue;
			if(strTemp.length() > 0) 
				strTemp += "<br>";				
			bolShowTD = true; 			
			iRowSpan0 = (int)(Double.parseDouble((String)vRetResult.elementAt(k+14)) - Double.parseDouble((String)vRetResult.elementAt(k+13))) * 2;					
			iRowSpan = iRowSpan0;
			strTemp += WI.getStrValue(vRetResult.elementAt(k+8),"<br>","")+
				WI.getStrValue(vRetResult.elementAt(k+7),"<br>","")+
				(String)vRetResult.elementAt(k+1)+":"+(String)vRetResult.elementAt(k+2)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+3))]+
					" to "+(String)vRetResult.elementAt(k+4)+":"+(String)vRetResult.elementAt(k+5)+convertAMPM[Integer.parseInt((String)vRetResult.elementAt(k+6))];
				
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);	
				vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);vRetResult.remove(k);		
				k-=16;	
		}
if(iRowSpan0 == 0 || iRowSpan0 > 0){
	
%>	
		<td align="center" rowspan="<%=iRowSpan%>"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
<%	
}	
if(iRowSpan0 > 0)
	iRowSpan0--;%>
	</tr>
<%}%>
</table>
  
  




<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
<tr><td height="18">&nbsp;</td></tr>
<tr><td height="25" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
to print schedule</font></td></tr>
<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>
<%
}//if student info not null
%>
<input type="hidden" name="reloadPage" value="0">
</form>
</body>
</html>
