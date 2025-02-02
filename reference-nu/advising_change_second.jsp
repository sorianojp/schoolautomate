<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>

<script language="JavaScript">
//if units to take is null or zero, give error.
function VerifyNotNull(index)
{
	var unitToTake = eval('document.advising.ut'+index+'.value');
	if(unitToTake.length ==0 || Number(unitToTake) <0.5)
	{
		alert("Please enter a unit to take.");
		eval('document.advising.ut'+index+'.focus()');
	}
}
/**
* call this function when input box is changed.
*/
var inFocusInputLoadVal = 0;
function SaveInputUnit(index)
{
	inFocusInputLoadVal = eval('document.advising.ut'+index+'.value');
}
function ChangeLoad(index)
{
	var maxAllowedInputLoad = eval('document.advising.total_unit'+index+'.value');
	var inputLoad = eval('document.advising.ut'+index+'.value');
	var maxAllowedLoad = document.advising.maxAllowedLoad.value;
	var totalLoad = Number(document.advising.sub_load.value) - Number(inFocusInputLoadVal);

	if(Number(inputLoad) > Number(maxAllowedInputLoad))
	{
		alert("Unit can't be more than "+maxAllowedInputLoad);
		eval('document.advising.ut'+index+'.value='+inFocusInputLoadVal);
		return;
	}
	if( eval("document.advising.checkbox"+index+".checked") )
	{
		document.advising.sub_load.value =Number(document.advising.sub_load.value) - Number(inFocusInputLoadVal)+Number(inputLoad);
	}
	inFocusInputLoadVal = inputLoad;
}
function checkAll()
{
	var maxDisp = document.advising.maxDisplay.value;
	var totalLoad = 0;
	//unselect if it is unchecked.
	if(!document.advising.selAll.checked)
	{
		for(var i =0; i< maxDisp; ++i)
		{
			eval('document.advising.checkbox'+i+'.checked=false');
			document.advising.sub_load.value = 0;
		}
		return;
	}
	for(var i =0; i< maxDisp; ++i)
	{
		if(	eval('document.advising.sec'+i+'.value.length')> 0)
		{
			totalLoad += Number(eval('document.advising.ut'+i+'.value'));
		}
	}
	if(totalLoad > eval(document.advising.maxAllowedLoad.value) )
	{
		alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load.");
		return;
	}
	else if(totalLoad == 0)
	{
		alert("Please sechedule to select student load.");
		return;
	}
	//this is the time I will check all.
	for(var i =0; i< maxDisp; ++i)
	{
		if(	eval('document.advising.sec'+i+'.value.length')> 0)
		{
			eval('document.advising.checkbox'+i+'.checked = true');
		}
	}
	document.advising.sub_load.value = totalLoad;

}

function ShowList()
{
	document.advising.showList.value = 1;
	//document.advising.submit();
	ReloadPage();
}
function ViewCurriculum()
{
	var pgLoc = "";
	if(document.advising.mn.value.length > 0)
		pgLoc = "../../admission/curriculum_page1.jsp?ci="+document.advising.ci.value+"&cname="+
			escape(document.advising.cn.value)+"&mi="+document.advising.mi.value+"&mname="+escape(document.advising.mn.value)+"&syf="+
			document.advising.syf.value+"&syt="+document.advising.syt.value+"&goNextPage=1&degree_type=0";
	else
		pgLoc = "../../admission/curriculum_page1.jsp?ci="+document.advising.ci.value+"&cname="+escape(document.advising.cn.value)+
			"&syf="+document.advising.syf.value+"&syt="+document.advising.syt.value+"&goNextPage=1&degree_type=0";

	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
/**
*	This displays Total load of the subjects seleced so far
*/
function AddLoad(index,subLoad)
{
//alert(subLoad+",,, "+document.advising.sub_load.value);
	//add if clicked and if not clicked remove it.
	if( eval("document.advising.checkbox"+index+".checked") )
	{
		document.advising.sub_load.value = Number(document.advising.sub_load.value) + Number(eval('document.advising.ut'+index+'.value'));
		if( Number(document.advising.sub_load.value) > Number(document.advising.maxAllowedLoad.value))
			alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load.");
	}
	else //subtract.
		document.advising.sub_load.value = Number(document.advising.sub_load.value) -Number(eval('document.advising.ut'+index+'.value'));
	if( Number(document.advising.sub_load.value) < 0)
		document.advising.sub_load.value = 0;

}
function LoadPopup(secName,sectionIndex, strCurIndex) //curriculum index is different for all courses.
{
//this will check conflict with the schedule of other subjects taken. pass user id, all the sub_section_index,
//if check box is not checked - it is considered as not selected.
	var subSecList = "";
	for(var i = 0; i< document.advising.maxDisplay.value; ++i)
	{
		if( eval('document.advising.checkbox'+i+'.checked') )
		{
			if(subSecList.length ==0)
				subSecList =eval('document.advising.sec_index'+i+'.value');
			else
				subSecList =subSecList+","+eval('document.advising.sec_index'+i+'.value');
		}
	}
	if(subSecList.length == 0) subSecList = "0";

	var loadPg = "./subject_schedule.jsp?form_name=advising&cur_index="+strCurIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.advising.sy_from.value+"&syt="+document.advising.sy_to.value+"&semester="+document.advising.semester.value+
		"&sec_index_list="+subSecList;
	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function Validate()
{
	if( Number(document.advising.sub_load.value) > Number(document.advising.maxAllowedLoad.value))
	{
		alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load. Please check the load referece on top of this page.");
		return false;
	}
	document.advising.action="./gen_advised_schedule.jsp";
	document.advising.submit();
	return true;
}
function ReloadPage()
{
	document.advising.action="./advising_change_second.jsp";
	document.advising.submit();
}
function BlockSection()
{
	var strMajorIndCon = document.advising.mi.value;
	if(strMajorIndCon.length == 0)
		strMajorIndCon = "";
	else
		strMajorIndCon="&mi="+strMajorIndCon;
	var loadPg = "./block_section.jsp?form_name=advising&max_disp="+document.advising.maxDisplay.value+"&ci="+
		document.advising.ci.value+strMajorIndCon+"&syf="+document.advising.syf.value+
	 	"&syt="+document.advising.syt.value+"&sy_from="+document.advising.sy_from.value+"&sy_to="+document.advising.sy_to.value+
	 	"&offering_sem="+document.advising.semester.value+
	 	"&year_level="+document.advising.year_level.value+"&semester="+document.advising.semester.value+
		"&cn="+escape(document.advising.cn.value)+"&mn="+escape(document.advising.mn.value);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=200,left=150,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strStudID = WI.fillTextValue("stud_id");
	int iMaxDisplayed = 0;
	boolean bolFatalErr = false;

	Vector[] vAutoAdvisedList = {null,null};//force it to null; - auto advise is not allwed for enrollees other than new/old.
	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-advising-Change course/Second course","advising_change_second.jsp");
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
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
														"advising_change_second.jsp");
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

String strMaxAllowedLoad = "0"; // this is the first field of the vAdvisingList
boolean bolShowAdviseList = false;
Vector vAdviseList = new Vector();

Vector vStudInfo = new Vector();
Vector vAllowedSubList = null;
astrSchYrInfo = dbOP.getCurSchYr();

Advising advising = new Advising();

if(astrSchYrInfo == null)//db error
{
	strErrMsg = dbOP.getErrMsg();
	bolFatalErr = true;
}
if(!bolFatalErr && strStudID.length() > 0)
{
	vStudInfo = advising.getStudInfo(dbOP,strStudID,astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	if(vStudInfo == null)
	{
		bolFatalErr = true;
		strErrMsg = advising.getErrMsg();
	}
	if(!bolFatalErr)
	{
		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),
			astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2],(String)vStudInfo.elementAt(4),
			(String)vStudInfo.elementAt(5));
		if(vMaxLoadDetail == null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
		else
			strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
	}
	if(!bolFatalErr && WI.fillTextValue("showList").compareTo("1") ==0) // show list.
	{
		bolShowAdviseList = true;
		vAdviseList = advising.getAdvisingListWOPreReq(dbOP,request.getParameter("ci"),request.getParameter("mi"),
						request.getParameter("sy_from"),request.getParameter("sy_to"), request.getParameter("syf"),
						request.getParameter("syt"),request.getParameter("year_level"),request.getParameter("semester"));
/*		System.out.println(vAdviseList);
		vAdviseList = advising.getAdvisingListForOLD(dbOP,strStudID, request.getParameter("ci"),request.getParameter("mi"),false,
						request.getParameter("sy_from"),request.getParameter("sy_to"), request.getParameter("syf"),
						request.getParameter("syt"),request.getParameter("year_level"),request.getParameter("semester"));
*/
		if(vAdviseList ==null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
	}
}

if(strErrMsg == null)
	strErrMsg = "";

%>

<body bgcolor="#D2AE72">
<form name="advising" action="" method="post" onSubmit="return Validate();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          CHANGE/SECOND COURSE STUDENT ADVISING PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8" bgcolor="#FFFFFF">
	  &nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
	</table>
<%
if(bolFatalErr)
{
	dbOP.cleanUP();
	return;
}
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="24%" height="25">Enter
        Temp. Student ID </td>
      <td width="22%" height="25">
	   <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
      </td>
      <td width="53%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
	    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="24%" height="25">School Year/Term </td>
      <td height="25" colspan="2"> <strong><%=astrSchYrInfo[0]%> - <%=astrSchYrInfo[1]%>
        / <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%></strong>
		<input type="hidden" name="semester" value="<%=astrSchYrInfo[2]%>">
        <input type="hidden" name="sy_from" value="<%=astrSchYrInfo[0]%>">
		<input type="hidden" name="sy_to" value="<%=astrSchYrInfo[1]%>">
      </td>
      <td width="0%" colspan="2">&nbsp; </td>
    </tr>

  </table>

<% if(vStudInfo != null && vStudInfo.size() > 0){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="62%" height="25">Student name (first,middle,last) :<strong>
        <%=(String)vStudInfo.elementAt(1)%>
        <input name="stud_name" value="<%=(String)vStudInfo.elementAt(1)%>" type="hidden">
        </strong></td>
      <td  colspan="3" height="25">Enrolling year level: <strong><%=(String)vStudInfo.elementAt(6)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">Enrolling course/major :<strong><%=(String)vStudInfo.elementAt(7)%>
        <%
		if(vStudInfo.elementAt(8) != null){%>
        / <%=(String)vStudInfo.elementAt(8)%>
        <%}%>
        </strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Curriculum SY :<strong><%=(String)vStudInfo.elementAt(4)%>
        - <%=(String)vStudInfo.elementAt(5)%></strong></td>
      <td  colspan="2" height="26">&nbsp;</td>
      <td width="9%" height="26">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td colspan="2" height="25"><hr size="1"></td>
    </tr>
    <tr >
      <td width="1%" height="25">&nbsp;</td>
      <td width="99%">Previous course/major :<strong> <%=(String)vStudInfo.elementAt(12)%>
        <%//System.out.println(vStudInfo);
		if(vStudInfo.elementAt(13) != null){%>
        / <%=(String)vStudInfo.elementAt(13)%>
        <%}%>
        </strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td  width="49%" height="25"><a href="javascript:ViewCurriculum();"><img src="../../../images/view.gif" width="40" height="31" border="0"></a><font size="1">click
        to view student's course curriculum</font></td>
      <td width="50%" height="25"><a href="javascript:ShowList();"><img src="../../../images/show_list.gif" width="57" height="34" border="0"></a><font size="1">click
        to show list of subjects student may take for the semester</font></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="2"><%=strErrMsg%></td>
    </tr>
  </table>

<%
if(bolShowAdviseList && vAdviseList != null && vAdviseList.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="4"><div align="center">LIST OF SUBJECTS THE STUDENT
          MAY TAKE</div></td>
    </tr>
    <tr>
      <td width="2%"  height="25">&nbsp;</td>
      <td height="25">Max units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>
      <td width="32%" height="25" colspan="-4">Total student load:
        <input type="text" name="sub_load" value="0" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;"></td>
      <td width="30%">
	  <a href="javascript:BlockSection();"><img src="../../../images/bsection.gif" width="62" height="24" border="0"></a>
	  <font size="1">click for block sectioning</font></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="6%" height="25" align="center"><font size="1"><strong>YEAR</strong></font></td>
      <td width="6%" height="25" align="center"><font size="1"><strong>TERM</strong></font></td>
      <td width="10%" height="25" align="center"><font size="1"><strong>SUBJECT
        CODE</strong></font></td>
      <td width="20%" align="center"><font size="1"><strong>SUBJECT NAME</strong></font></td>
      <td width="12%" align="center"><font size="1"><strong>SUBJECT PRE-REQUISITE</strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>LEC/LAB UNITS</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>TOTAL UNITS</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>UNITS TO TAKE</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>SECTION</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong><font size="1">SELECT
        ALL</font></strong> <br>
        <input type="checkbox" name="selAll" value="0" onClick="checkAll();">
        </font></td>
      <td width="10%" align="center"><font size="1"><strong>ASSIGN SECTION</strong></font></td>
    </tr>
    <% int iTemp = 0;
String strBlockSection = WI.fillTextValue("block_sec");
for(int i = 0,j=0 ; i< vAdviseList.size() ; ++i,++j,++iMaxDisplayed)
{
	strTemp = ""; strTemp2 = "";
	if(vAutoAdvisedList[1] != null && (iTemp = vAutoAdvisedList[1].indexOf(vAdviseList.elementAt(i+6))) != -1)
	{
		strTemp = (String)vAutoAdvisedList[1].elementAt(iTemp-2); //section index.
		strTemp2 = (String)vAutoAdvisedList[1].elementAt(iTemp-1);//section name.
	}
	else if(strBlockSection.length() > 0)//check if block section is called.if so - then display the section information only if the block section available for the year and the section
	{
		//check if year and sem are same as it is for block sections.
		if(WI.fillTextValue("year_level").compareTo((String)vAdviseList.elementAt(i+1)) == 0 &&
			WI.fillTextValue("semester").compareTo((String)vAdviseList.elementAt(i+2)) == 0)//matching ;-)
		{
			strTemp2 = strBlockSection;
			strTemp = advising.getSubSecIndex(dbOP,(String)vAdviseList.elementAt(i),strBlockSection,request.getParameter("sy_from"),
							request.getParameter("sy_to"),request.getParameter("semester"));
			if(strTemp == null)
			{strTemp2 = "";strTemp="";}
		}

	}
%>
    <tr>
      <td height="25" align="center">
        <!-- all the hidden fileds are here. -->
        <input type="hidden" name="year_level<%=j%>" value="<%=(String)vAdviseList.elementAt(i+1)%>">
        <input type="hidden" name="sem<%=j%>" value="<%=(String)vAdviseList.elementAt(i+2)%>">
        <input type="hidden" name="sub_code<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>">
        <input type="hidden" name="sub_name<%=j%>" value="<%=(String)vAdviseList.elementAt(i+7)%>">
        <input type="hidden" name="lab_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+4)%>">
        <input type="hidden" name="lec_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+3)%>">
        <input type="hidden" name="total_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>">
        <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vAdviseList.elementAt(i)%>">
        <%=(String)vAdviseList.elementAt(i+1)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+2)%></td>
      <td><%=(String)vAdviseList.elementAt(i+6)%>
        <%if(((String)vAdviseList.elementAt(i+6)).indexOf("NSTP") != -1){
strTempStudId = WI.fillTextValue("nstp_val");%>
        <select name="nstp_val<%=j%>" style="font-weight:bold;">
          <option value="CWTS">CWTS</option>
          <%
if(strTempStudId.compareTo("LTS") ==0){%>
          <option value="LTS" selected>LTS</option>
          <%}else{%>
          <option value="LTS">LTS</option>
          <%}if(strTempStudId.compareTo("ROTC") ==0){%>
          <option value="ROTC" selected>ROTC</option>
          <%}else{%>
          <option value="ROTC">ROTC</option>
          <%}%>
        </select>
        <%}//only if subject is NSTP %>
      </td>
      <td><%=(String)vAdviseList.elementAt(i+7)%></td>
      <td align="center"><%=WI.getStrValue(vAdviseList.elementAt(i+8),"&nbsp;")%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+3)%>/<%=(String)vAdviseList.elementAt(i+4)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+5)%></td>
      <td align="center">
        <%
strTemp = WI.fillTextValue("ut"+j);
if(strTemp.length() ==0)
	strTemp = (String)vAdviseList.elementAt(i+5);
%>
        <input name="ut<%=j%>" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'; javascript:SaveInputUnit(<%=j%>);" onBlur="style.backgroundColor='white'; javascript:VerifyNotNull(<%=j%>);"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" onKeyUp='ChangeLoad("<%=j%>");'></td>
      <td> <input type="text" value="<%=strTemp2%>" name="sec<%=j%>" size="12" readonly="yes" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;">
        <input type="hidden" value="<%=strTemp%>" name="sec_index<%=j%>"> </td>
      <td align="center"> <input type="checkbox" name="checkbox<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>" onClick='AddLoad("<%=j%>","<%=(String)vAdviseList.elementAt(i+5)%>")'>
      </td>
      <td align="center"><a href='javascript:LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>");'><img src="../../../images/schedule.gif" width="55" height="30" border="0"></a></td>
    </tr>
    <% i = i+8;}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8"><div align="right"></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8"><div align="center"> <input type="image" src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8">&nbsp; </td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <%}//end of displaying the advise list if bolShowAdviseList is TRUE
 %>
 <%
 //print error message if vAdviseList is null or not having any information.
 if(vAdviseList == null || vAdviseList.size() ==0)
 {
 strTemp = advising.getErrMsg();
 if(strTemp == null && WI.fillTextValue("showList").compareTo("1") ==0 )
 	strTemp = "Please try again. If same Error continues please contact system admin to check error status.";
 if(strTemp == null) strTemp = "";
 %>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25"><strong><%=strTemp%></strong></td>
    </tr>
  </table>
 <%} // shows error message.%>



<!-- the hidden fields only if temp user exist -->
<input type="hidden" name="cn" value="<%=(String)vStudInfo.elementAt(7)%>">
<input type="hidden" name="ci" value="<%=(String)vStudInfo.elementAt(2)%>">
<input type="hidden" name="mn" value="<%=WI.getStrValue(vStudInfo.elementAt(8))%>">
<input type="hidden" name="mi" value="<%=WI.getStrValue(vStudInfo.elementAt(3))%>">
<input type="hidden" name="syf" value="<%=(String)vStudInfo.elementAt(4)%>">
<input type="hidden" name="syt" value="<%=(String)vStudInfo.elementAt(5)%>">
<input type="hidden" name="maxDisplay" value="<%=iMaxDisplayed%>"><!-- max number of entries displayed.-->
<input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(6)%>">


<%} // end of display - if student id is valid
%>

<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="showList" value="<%=WI.fillTextValue("showList")%>">
<input type="hidden" name="viewAllAllowedLoad" value="<%=WI.fillTextValue("viewAllAllowedLoad")%>">
<input type="hidden" name="maxAllowedLoad" value="<%=strMaxAllowedLoad%>">
<input type="hidden" name="block_sec"><!-- contains value for block section.-->
<%
strTemp = WI.fillTextValue("accumulatedLoad");
if(strTemp.length() ==0)
	strTemp = "0";
%>
<input type="hidden" name="accumulatedLoad" value="<%=strTemp%>">
<input type="hidden" name="stud_type" value="Change Course">




</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
