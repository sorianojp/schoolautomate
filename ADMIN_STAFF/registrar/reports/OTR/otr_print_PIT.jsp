<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM2 {
    border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM2RIGHT {
    border-bottom: solid 2px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderRIGHTBOTTOM {
    border-right: solid 1px #000000;
    border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

	TD.thinborderLEFTBOTTOM2 {
    border-left: solid 1px #000000;
    border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderLEFTRIGHTBOTTOM {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

	TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	TD.thinborderLEFTRIGHTBOTTOM2 {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<script language="javascript">
function HideImg() {
	document.getElementById('hide_img').innerHTML = "";
}
function UpdateLabel(strLevelID) {
	var newVal = prompt('Please enter new Value');
	if(newVal == null)
		return;
	document.getElementById(strLevelID).innerHTML = newVal;
}
function autoShrink(strLevelID) {
	var strFieldVal = document.getElementById(strLevelID).innerHTML;
	//shrink from 6,7,8,9,10,11,12,13
	var iLen = 0;
	var newPX = "";
	if(strFieldVal.indexOf("6px") > 0) {
		newPX = "13px";
		iLen = 1;
	}
	else if(strFieldVal.indexOf("7px") > 0)
		newPX = "6px";
	else if(strFieldVal.indexOf("8px") > 0)
		newPX = "7px";
	else if(strFieldVal.indexOf("9px") > 0)
		newPX = "8px";
	else if(strFieldVal.indexOf("10px") > 0)
		newPX = "9px";
	else if(strFieldVal.indexOf("11px") > 0) {
		newPX = "10px";
		iLen = 1;
	}
	else if(strFieldVal.indexOf("12px") > 0) {
		newPX = "11px";
		iLen = 1;
	}
	else if(strFieldVal.indexOf("13px") > 0) {
		newPX = "12px";
		iLen = 1;
	}
	else {	
		newPX = "10px";
		iLen = 1;
	}
	//<font style='font-size:10px;'>Field Value..</font>
	var newVal = strFieldVal;//alert(newVal);
	if(newVal.indexOf("<font") > -1) {
		var iIndexOf = newVal.indexOf(">");
		newVal = newVal.substring(iIndexOf + 1);//alert("print with font in it : "+newVal);
		newVal = newVal.substring(0,newVal.length - 7);
	}
	//alert("Only item :: "+newVal);
	newVal = "<font style='font-size:"+newPX+";'>"+newVal+"</font>";
	//alert(newVal);
	document.getElementById(strLevelID).innerHTML = newVal;
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDegreeType = null;

	String strCollegeName = null;//I have to find the college offering course.

	int iRowStartFr = Integer.parseInt(WI.fillTextValue("row_start_fr"));
	int iRowCount   = Integer.parseInt(WI.fillTextValue("row_count"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"),"0"));

	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.fillTextValue("max_page_to_disp"));

	int iLastIndex = -1;

	int iPageNumber = Integer.parseInt(WI.fillTextValue("page_number"));
	String strTotalPageNumber = WI.fillTextValue("total_page");


	String strImgFileExt = null;
	String strRootPath  = null;
	String strTemp2 = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-OTR","otr_print.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strRootPath = readPropFile.getImageFileExtn("installDir");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}

		if(strRootPath == null || strRootPath.trim().length() ==0)
		{
			strErrMsg = "Installation directory path is not set.  " +
						 " Please check the property file for installDir KEY.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"otr_print.jsp");
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
Vector vStudInfo = null;
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vGraduationData = null;
Vector vRetResult  = null;
Vector vCompliedRequirement = null;
Vector vStudRequirements = null;

Vector vMulRemark = null;
int iMulRemarkIndex = -1;


String[] astrConvertSem = {"Summer","1st Sem.","2nd Sem.","3rd Sem.",""};

enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.CourseRequirement cRequirement = new enrollment.CourseRequirement();

//repRegistrar.strTFList = "0";//remvoe all transferee info.. 


if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		strCollegeName = new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(5));
		if(strCollegeName != null)
			strCollegeName = strCollegeName.toUpperCase();

		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
			(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
	}
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();
	vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);
	vGraduationData = entranceGradData.operateOnGraduationData(dbOP,request,4);
	if(vEntranceData == null || vGraduationData == null)
		strErrMsg = entranceGradData.getErrMsg();

	Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,request.getParameter("stud_id"),
														(String)vStudInfo.elementAt(7),
													(String)vStudInfo.elementAt(8));
		if (vFirstEnrl != null) {
			vStudRequirements = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
											(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
											(String)vFirstEnrl.elementAt(2),false,false,true,true);

		if(vStudRequirements == null && strErrMsg == null)
			strErrMsg = cRequirement.getErrMsg();
		else {
			vCompliedRequirement = (Vector)vStudRequirements.elementAt(1);
		}
	  }else strErrMsg = cRequirement.getErrMsg();
}

//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else {
		vMulRemark = (Vector)vRetResult.remove(0);
		
		int iIndexOf = 0;
		Vector vEnrichmentSubjects = null;
		boolean bolPutParanthesis = false;
		vEnrichmentSubjects = new enrollment.GradeSystem().getEnrichmentSubject(dbOP);
		
		//I have to check here -- for PIT, if grade is 4, student can take re-exam. Problem now is , as it is order by asc, in re-exam if student pass, then the grade is 
		//less, so it goes first. but if fails, the arrangement is correct, so i have to check only the subject with grade 4.0, but garde is after the passing grade.
		for(int i = 0; i < vRetResult.size(); i += 11) {
			if(vRetResult.elementAt(i + 8) == null)
				continue;
			//this piece of code, converts the non-credit unit subject to unit with ()
			iIndexOf = vEnrichmentSubjects.indexOf(vRetResult.elementAt(i + 6));
			if(iIndexOf == -1) {
				strTemp = (String)vRetResult.elementAt(i + 6);
				if(strTemp.startsWith("NSTP")) {
					if(strTemp.endsWith("(CWTS)")) {
						strTemp = strTemp.substring(0,strTemp.length() - 6);
						iIndexOf = vEnrichmentSubjects.indexOf(strTemp);
					}
					if(strTemp.endsWith("(ROTC)")) {
						strTemp = strTemp.substring(0,strTemp.length() - 6);
						iIndexOf = vEnrichmentSubjects.indexOf(strTemp);
					}
				}
			
			
			}
				
				
			if(iIndexOf > -1) {
				try {
					double dGrade = Double.parseDouble((String)vRetResult.elementAt(i + 8));
					strTemp = (String)vRetResult.elementAt(i + 9);System.out.println(strTemp);
					
					if(dGrade > 0d && (dGrade < 4d || dGrade >= 75d) && !strTemp.startsWith("(") ) {
						strTemp = "(" + (String)vEnrichmentSubjects.elementAt(iIndexOf + 3) + ")";
						vRetResult.setElementAt(strTemp, i + 9);
					}
					
				}
				catch(Exception e){}
			}
			
		
		
			if(i == 0) 
				continue;
			if(!vRetResult.elementAt(i + 8).equals("4.0"))
				continue;
			if(!vRetResult.elementAt(i + 1).equals(vRetResult.elementAt(i - 11 + 1)) ||  //sy is not same.
				!vRetResult.elementAt(i + 3).equals(vRetResult.elementAt(i - 11 + 3)) || //sem 
				!vRetResult.elementAt(i + 6).equals(vRetResult.elementAt(i - 11 + 6)) || //sub_code
				!vRetResult.elementAt(i + 7).equals(vRetResult.elementAt(i - 11 + 7)) ) { //sub_name.
			
					continue;
			}
			//swap..vTemp.setElementAt(obj, int); 
			vRetResult.setElementAt(vRetResult.elementAt(i - 11 + 9), i + 9);//credit earned.
			vRetResult.setElementAt(vRetResult.elementAt(i - 11 + 8), i + 8);//grade
			vRetResult.setElementAt("4.0", i -11 + 8);
		}
		//end of swap.. 
	}	
}



String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);

String[] astrLecLabHr = null;//gets lec/lab hour information.
String strRLEHrs    = null;
String strCE        = null;

boolean bolIsMarine = true;
if(vStudInfo != null && vStudInfo.elementAt(7) != null) {
	if(((String)vStudInfo.elementAt(7)).toLowerCase().indexOf("marine") > -1)
		bolIsMarine = true;
}
//System.out.println(vMulRemark);
%>

<body topmargin="5">

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width=89 align="left" valign="top">&nbsp;</td>
    <td width="47" align="left" valign="top">&nbsp;</td>
    <td width="527" height="150" align="center" valign="top" style="font-size:12px;"><br><br><br><br><br>
	Office of the Registrar<br>
	<font style="font-size:18px; font-weight:bold">OFFICIAL TRANSCRIPT OF RECORDS</font>		</td>
    <td width="84" style="font-size:9px;" valign="top">
	<%if(bolIsMarine && false) {%>
	issued Date: 3/10/79<br>
  	Revision Status: 02<br>
  	Reviewed by: QAM<br>
  	Approved by: President<br> 
  	QF-OR-011
	<%}%>
	</td>
    <td width="101">
<%
		strTemp = WI.fillTextValue("stud_id");
		//System.out.println("strTemp : " + strTemp);
		//System.out.println(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);
		if (strTemp.length() > 0) {
			java.io.File file = new java.io.File(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);

			if(file.exists()) {
				strTemp = "../../../../upload_img/"+strTemp+"."+strImgFileExt;
				strTemp = "<label id='hide_img' onClick='HideImg()'><img src=\""+strTemp+"\" width=125 height=125></label>";
			}
			else {
				strTemp = "&nbsp;";
			}
		}
%>
	<%//if(iLastPage == 1){%><%=strTemp%><%//}%><br></td>
  </tr>
</table>
<%
boolean bolShrink = false;//shrink name.
if(((String)vStudInfo.elementAt(0)).length() > 21 || WI.getStrValue(vStudInfo.elementAt(1)).length() > 21 ||
	((String)vStudInfo.elementAt(2)).length() > 21)
	bolShrink = true;
%>

<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td height="18" colspan="5"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="6%"><strong>Name:</strong></td>
        <td width="5%">&nbsp;</td>
        <td width="27%" align="center" class="thinborderBOTTOM"><strong>
		<font style="font-size:<%if(bolShrink){%>10px<%}else{%>13px<%}%>">
			<label id="aShrink-01" onClick="autoShrink('aShrink-01');"><%=((String)vStudInfo.elementAt(2)).toUpperCase()%></label></font></strong></td>
        <td width="5%">&nbsp;</td>
        <td width="25%" align="center" class="thinborderBOTTOM" style="font-size:13px"><strong><label id="aShrink-02" onClick="autoShrink('aShrink-02');"><%=((String)vStudInfo.elementAt(0)).toUpperCase()%></label></strong></td>
        <td width="5%">&nbsp;</td>
        <td width="25%" align="center" class="thinborderBOTTOM" style="font-size:13px"><strong><label id="aShrink-03" onClick="autoShrink('aShrink-03');"><%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></label></strong></td>
        <td width="2%">&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td valign="top"><div align="center"><strong>Family Name </strong></div></td>
        <td>&nbsp;</td>
        <td valign="top"><div align="center"><strong>First Name </strong></div></td>
        <td>&nbsp;</td>
        <td align="center" valign="top"><strong>Middle Name </strong></td>
        <td>&nbsp;</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td height="18" colspan="5"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="11%"><strong>Student No: </strong></td>
        <td width="11%" class="thinborderBOTTOM"><strong><label id="aShrink-04" onClick="autoShrink('aShrink-04');"><%=WI.fillTextValue("stud_id").toUpperCase()%></label></strong></td>
        <td width="5%"> <strong>&nbsp;&nbsp;Sex: </strong></td>
        <td width="4%" class="thinborderBOTTOM"><div align="center"><strong><%=(String)vStudInfo.elementAt(16)%></strong></div></td>
        <td width="12%"><strong>&nbsp;Date of Birth: </strong></td>
        <td width="20%" class="thinborderBOTTOM"><strong>
		<%=WI.getStrValue(vAdditionalInfo.elementAt(1))%>
		</strong></td>
        <td width="13%"><strong>&nbsp;Place of Birth: </strong></td>
        <td width="24%" class="thinborderBOTTOM"><strong><label id="aShrink-07" onClick="autoShrink('aShrink-07');"><%=WI.getStrValue(vAdditionalInfo.elementAt(2))%></label></strong></td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td height="18" colspan="5"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="7%"><strong>Address: </strong></td>
        <td width="24%" class="thinborderBOTTOM"><strong>
			<font style="font-size:11px"><label id="aShrink-08" onClick="autoShrink('aShrink-08');"><%=WI.fillTextValue("address")%></label></font>
			</strong></td>
        <td width="15%"><strong>&nbsp;Date of Graduation:</strong></td>
        <td width="17%" class="thinborderBOTTOM"><strong>
          <%if(vGraduationData != null)
	strTemp = (String)vGraduationData.elementAt(8);
else
	strTemp = "";

	if (strTemp != null && strTemp.length() !=0)
		strTemp= WI.formatDate(strTemp,10);
	else
		strTemp = "";


	iLastIndex = -1;
	if (((String)vStudInfo.elementAt(7)).length() > 25){
		iLastIndex = ((String)vStudInfo.elementAt(7)).lastIndexOf(' ',25);
	}
%>
		&nbsp;<label id="aShrink-09" onClick="autoShrink('aShrink-09');"><%=strTemp%></label></strong></td>
        <td width="13%"><strong> &nbsp;Title / Degree: </strong></td>
        <td width="24%" class="thinborderBOTTOM"><strong>
          <% if (iLastIndex != -1){%>
            <label id="aShrink-13" onClick="autoShrink('aShrink-13');"><%=((String)vStudInfo.elementAt(7)).substring(0,iLastIndex)%></label>
            <%}else{%>
            <label id="aShrink-13" onClick="autoShrink('aShrink-13');"><%=(String)vStudInfo.elementAt(7)%></label>
            <%}%></strong>
		  </td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td height="18" colspan="5"><table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="7%">&nbsp;</td>
        <td width="24%" class="thinborderBOTTOM"><strong>
          <label id="aShrink-11" onClick="autoShrink('aShrink-11');"><%=WI.fillTextValue("address2")%></label></strong></td>
        <td width="12%">
&nbsp;
<%
	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
		strTemp = dbOP.mapOneToOther("course_offered join college on " +
									 "(course_offered.c_index = college.c_Index)",
									 "course_name", "'" + (String)vStudInfo.elementAt(7) +"'",
									 "c_name", " and course_offered.is_del = 0" +
									 " and college.is_del= 0");
		if (strTemp == null) {
			strTemp ="&nbsp;";
		}else{
			strTemp =  strTemp.substring(strTemp.indexOf("of") + 3);
		}
	}else{
		strTemp = "&nbsp;";
	}
%>


		<strong>College:</strong></td>
        <td width="20%" class="thinborderBOTTOM"><strong>
          <label id="aShrink-12" onClick="autoShrink('aShrink-12');"><%=strTemp%></label></strong></td>
        <td width="13%">&nbsp;</td>
        <td width="24%" class="thinborderBOTTOM">
          <strong>
            <% if (iLastIndex != -1){%>
            <label id="aShrink-15" onClick="autoShrink('aShrink-15');"><%=((String)vStudInfo.elementAt(7)).substring(iLastIndex)%></label>
            <%}%>
        </strong></td>
      </tr>
    </table></td>
  </tr>
  <tr>
<% strTemp ="";
 if (vCompliedRequirement != null && vCompliedRequirement.size() > 0) {
	for (int k = 0; k < vCompliedRequirement.size(); k+= 3) {
		strTemp2 = (String)vCompliedRequirement.elementAt(k+1);
		if (strTemp2.toLowerCase().startsWith("birth"))
			strTemp2 = "Birth Cert.";
		if (k == 0) strTemp = strTemp2;
		else strTemp +="," + strTemp2;
	}
 }

%>
    <td height="18" colspan="5"><table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="10%"><strong>Entrance Data: </strong></td>
        <td width="53%" class="thinborderBOTTOM"><strong>
          <label id="aShrink-14" onClick="autoShrink('aShrink-14');"><%=strTemp%></label></strong></td>
        <td width="13%"><strong> &nbsp;Major:</strong></td>
        <td width="24%" class="thinborderBOTTOM" style="font-weight:bold">
		<%=WI.getStrValue((String)vStudInfo.elementAt(8))%>
		</td>
      </tr>
    </table></td>
  </tr>
</table>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td colspan="2"><strong>Preliminary Education </strong></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td width="10%">&nbsp;</td>
    <td width="50%"><div align="center"><strong>School</strong></div></td>
    <td width="6%">&nbsp;</td>
    <td width="19%"><div align="center"><strong>Year</strong></div></td>
    <td width="15%">&nbsp;</td>
  </tr>
  <tr>
    <td height="15"><strong>Elementary:</strong></td>
    <td class="thinborderBOTTOM"><div align="">
        <strong>
<%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(14),WI.getStrValue(vEntranceData.elementAt(3)));
else
	strTemp = "&nbsp;";

bolShrink = false;
if(strTemp.length() > 47)
	bolShrink = true;
%>
        <font style="font-size:<%if(bolShrink){%>9px;<%}else{%>11px;<%}%>"><label id="aShrink-16" onClick="autoShrink('aShrink-16');"><%=strTemp%></label></font></strong></div></td>
    <td>&nbsp;</td>
    <td class="thinborderBOTTOM"><div align="center">
      <strong>
      <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(18),"&nbsp;");
else
	strTemp = "&nbsp;";
%>
      <label id="aShrink-18" onClick="autoShrink('aShrink-18');"><%=strTemp%></label></strong></div></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="19"><strong>Secondary:</strong></td>
    <td class="thinborderBOTTOM"><div align="">
        <strong>
        <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(5),"&nbsp;");
else
	strTemp = "&nbsp;";
bolShrink = false;
if(strTemp.length() > 47)
	bolShrink = true;
%>

        <font style="font-size:<%if(bolShrink){%>9px;<%}else{%>11px;<%}%>"><label id="aShrink-17" onClick="autoShrink('aShrink-17');"><%=strTemp%></label></font></strong></div></td>
    <td>&nbsp;</td>
    <td class="thinborderBOTTOM"><div align="center">
      <strong>
      <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(22),"&nbsp;");
else
	strTemp = "&nbsp;";
%>
      <label id="aShrink-19" onClick="autoShrink('aShrink-19');"><%=strTemp%></label></strong></div></td>
    <td>&nbsp;</td>
  </tr>
</table>

<%

if(vRetResult != null && vRetResult.size() > 0){

%>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr bgcolor="#FFFFFF">
    <td height="17" colspan="5" class="thinborderBOTTOM2"><font size="1">&nbsp;</font></td>
  </tr>
  <tr bgcolor="#FFFFFF">
    <td width="18%" rowspan="2" align="center" class="thinborderBOTTOM2RIGHT"><strong>COURSE NUMBER </strong></td>
    <td width="43%" rowspan="2" class="thinborderBOTTOM2"><div align="center"><strong>DESCRIPTIVE TITLE </strong></div></td>
    <td colspan="2" class="thinborderLEFTRIGHTBOTTOM"><div align="center"><strong>GRADES</strong></div>
    </td>
    <td width="9%" rowspan="2" class="thinborderBOTTOM2" align="center"><strong>CREDITS</strong></td>
  </tr>
  <tr bgcolor="#FFFFFF">
    <td width="8%" class="thinborderLEFTRIGHTBOTTOM2"><div align="center"><strong>Final</strong></div></td>
    <td width="8%" class="thinborderRIGHTBOTTOM"><div align="center"><strong>Re-Exam</strong></div></td>
  </tr>
  <%//System.out.println(vRetResult);
int iLevelID = 0;

int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
String strSchoolName = null;
String strPrevSchName = "";
String strSchNameToDisp = null;

String strSYSemToDisp   = null;
String strCurSYSem      = null;
String strPrevSYSem     = null;

boolean bolIsSchNameNull    = false;
boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has
//school name after it is null, it is encoded as cross enrollee.

String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;//System.out.println(vRetResult);

String strCrossEnrolleeSchPrev   = null;
String strCrossEnrolleeSch       = null;
for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){
//I have to now check if this subject is having RLE hours.
//String strRLEHrs    = null;
//String strCE        = null;

	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && /**((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 &&**/ vRetResult.elementAt(i + 6 + 11) != null && vRetResult.elementAt(i + 6 + 11) != null &&
		WI.getStrValue(vRetResult.elementAt(i + 6)).equals(WI.getStrValue(vRetResult.elementAt(i + 6 + 11))) && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).equals((String)vRetResult.elementAt(i + 1 + 11))  && //sy_from
		((String)vRetResult.elementAt(i + 2)).equals((String)vRetResult.elementAt(i + 2 + 11)) && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").equals(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1"))) {   //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
	}
	else {
		strTemp = (String)vRetResult.elementAt(i + 9);
	}
	strCE        = strTemp;
	if(strTemp != null && strTemp.indexOf("hrs") > 0 && strTemp.indexOf("(") > 0) {
		strRLEHrs = CommonUtil.formatGrade(strTemp.substring(strTemp.indexOf("(") + 1, strTemp.indexOf("hrs")),0f);
		strCE     = strTemp.substring(0,strTemp.indexOf("("));
	}
	else {
		strRLEHrs    = null;
	}



	strSchoolName = (String)vRetResult.elementAt(i);

	if(vRetResult.elementAt(i) == null)
		bolIsSchNameNull = true;

	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) //cross enrolled.
		strSchoolName += " (CROSS ENROLLED)";

/** uncomment this if school name apprears once. */
	if(i == 0 && strSchoolName == null) {//I have to get the current school name
		strSchNameToDisp = SchoolInformation.getSchoolName(dbOP,false,false);
		strSchoolName = strSchNameToDisp;
	}

	if (WI.getStrValue(strSchoolName).length() == 0)
		strSchoolName = strCurrentSchoolName;

	if(strPrevSchName.equals(WI.getStrValue(strSchoolName))) {
		strSchNameToDisp = null;
	} else {//itis having a new school name.
		strPrevSchName = strSchoolName;
		strSchNameToDisp = strPrevSchName;
	}


//strCurSYSem =
if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.
	if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
		strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))];
	} else {
		strCurSYSem = (String)vRetResult.elementAt(i+ 3);
	}

	if (strCurSYSem != null && strCurSYSem.length() > 0){
		if (strCurSYSem.toLowerCase().startsWith("sum")){
			strCurSYSem += " " +  (String)vRetResult.elementAt(i+ 2);
		}else{
			strCurSYSem += " " + (String)vRetResult.elementAt(i+ 1)+ " - " +
							(String)vRetResult.elementAt(i+ 2);
		}
	}

	if(strCurSYSem != null) {
		if(strPrevSYSem == null) {
			strPrevSYSem = strCurSYSem ;
			strSYSemToDisp = strCurSYSem;
		}
		else if(strPrevSYSem.equals(strCurSYSem)) {
			strSYSemToDisp = null;
		}
		else {//itis having a new school name.
			strPrevSYSem = strCurSYSem;
			strSYSemToDisp = strPrevSYSem;
		}
	}
}

	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//cross enrolled.
		if(strCrossEnrolleeSchPrev == null || strCrossEnrolleeSchPrev.compareTo(strSchoolName) != 0)  {
			strCrossEnrolleeSchPrev = strSchoolName;
			strCrossEnrolleeSch     = strSchoolName;
			strSYSemToDisp = strCurSYSem;
		}
	}

//to convert 1ST SEMESTER to 1st Sem
if(strSYSemToDisp != null) {
	if(strSYSemToDisp.indexOf("SEMESTER") > 0) {
		strSYSemToDisp = strSYSemToDisp.toLowerCase();
		int iIndex = strSYSemToDisp.indexOf("semester");

		strSYSemToDisp = strSYSemToDisp.substring(0, 3) + " Sem"+
			strSYSemToDisp.substring(12);
	}
	if(strSYSemToDisp.startsWith("SUMMER"))
		strSYSemToDisp = "Summer"+strSYSemToDisp.substring(6);
	if(strSYSemToDisp.indexOf("TRIMESTER") != -1) {
		int iIndex = strSYSemToDisp.indexOf("TRIMESTER");
		strSYSemToDisp = strSYSemToDisp.substring(0,iIndex) + "TRI" +
						strSYSemToDisp.substring(iIndex+9);
	}

}



 //Very important here, it print <!-- if it is not to be shown.
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){strHideRowLHS = "<!--";//I have to do this so i will know if I am priting data or not%>
  <%=strHideRowLHS%>
  <%}else {++iRowsPrinted;strHideRowLHS = "";}//actual number of rows printed.

if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
	vMulRemark.removeElementAt(0);%>
  <tr bgcolor="#FFFFFF">
    <td height="20" colspan="5" align="center" class="thinborderTOPBOTTOM"><strong>
		<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></label>
	</strong></td>
  </tr>
  <%}//end of if
}//end of vMulRemark.

if(strSYSemToDisp != null){%>
  <tr bgcolor="#FFFFFF">
    <td height="17" style="font-size:12px;"><strong> <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strSYSemToDisp%></label>
    </strong></td>
    <td height="17" class="thinborderLEFT" style="font-size:12px;"><div align="center"><strong>&nbsp;<u><%=WI.getStrValue(strSchNameToDisp).toUpperCase()%></u></strong></div></td>
    <td class="thinborderLEFTRIGHT" >&nbsp;</td>
    <td class="thinborderRIGHT" >&nbsp;</td>
    <td >&nbsp;</td>
  </tr>
  <%}
%>
  <tr bgcolor="#FFFFFF">
    <td><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')" style="font-size:12px;"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></label></td>
    <td class="thinborderLEFT" style="font-size:12px;"><%=vRetResult.elementAt(i + 7)%></td>
    <%
if(WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;").compareTo("on going") == 0){%>
    <td colspan="3" style="font-size:12px;">&nbsp;&nbsp;Grade not ready</td>
    <%}else{
	strTemp = WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;");
	//if(strTemp.length() == 3 && strTemp.indexOf(".") == 1)
		//strTemp = strTemp + "0";
	%>

    <td width="2%" align="center" class="thinborderLEFTRIGHT" style="font-size:12px;"><%=strTemp%></td>
    <td width="2%" align="center" class="thinborderRIGHT" style="font-size:12px;"><%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && /**((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 &&**/ vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null &&
		(WI.getStrValue((String)vRetResult.elementAt(i + 6))).compareTo(WI.getStrValue((String)vRetResult.elementAt(i + 6 + 11))) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);

			%>
        <%=(String)vRetResult.elementAt(i + 8 + 11)%>
        <%i += 11;}else{%>&nbsp;
		<%}%></td>
    <td width="10%" align="center" style="font-size:12px;">&nbsp;
	<%
	if(strCE.indexOf(".") > -1)
		strCE = CommonUtil.formatFloat(strCE,false);
	%>
	<%=strCE%>
        <%//if(strTemp != null) {%>
        <%//=strTemp%>
        <%//}else{%>
        <%//=WI.getStrValue(vRetResult.elementAt(i + 9))%>
        <%//}%>    </td>
    <%}//sho only if grade is not on going.%>
  </tr>
<%
 if(vMulRemark != null && vMulRemark.size() > 0 && (i + 11) >= vRetResult.size()) {
 	vMulRemark.removeElementAt(0);%>
   <tr bgcolor="#FFFFFF">
     <td height="20" colspan="5" align="center" class="thinborderTOPBOTTOM"><strong>
 		<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></label>
 	</strong></td>
   </tr>
   <%}//end of if%>
   
  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%>
  <%}
   }//end of for loop
	if (iLastPage != 1){
%>
<tr>
	<td class="thinborderBOTTOM2">&nbsp;</td>
	<td height="17" class="thinborderLEFTBOTTOM2"><div align="center">
					<strong>next page please</strong></div>	</td>
    <td class="thinborderLEFTRIGHTBOTTOM2" >&nbsp;</td>
    <td class="thinborderRIGHTBOTTOM" >&nbsp;</td>
    <td class="thinborderBOTTOM2" >&nbsp;</td>
</tr>
<%}else{
	iRowsPrinted++;
%>
<tr>
	<td class=>&nbsp;</td>
	<td height="17" class="thinborderLEFT" style="font-weight:bold"><div align="center">-X-X-X- TRANSCRIPT CLOSED -X-X-X-</div></td>
	<td class="thinborderLEFTRIGHT" >&nbsp;</td>
	<td class="thinborderRIGHT" >&nbsp;</td>
	<td >&nbsp;</td>
</tr>

<%
iRowsPrinted = iRowsPrinted +1;
for(;iRowsPrinted < iMaxRowToDisp-1; ++ iRowsPrinted){ %>
<tr>
	<td class=>&nbsp;</td>
	<td height="17" class="thinborderLEFT" >&nbsp;</td>
	<td class="thinborderLEFTRIGHT" >&nbsp;</td>
	<td class="thinborderRIGHT" >&nbsp;</td>
	<td >&nbsp;</td>
</tr>

<%}%>
<tr>
	<td height="17" class="thinborderBOTTOM2">&nbsp;</td>
	<td class="thinborderLEFTBOTTOM2">&nbsp;</td>
	<td class="thinborderLEFTRIGHTBOTTOM2">&nbsp;</td>
	<td class="thinborderRIGHTBOTTOM">&nbsp;</td>
	<td class="thinborderBOTTOM2">&nbsp;</td>
</tr>

<%
} // end if else last page%>
</table>
<%}//only if student is having grade infromation.%>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
<tr>
	<td width="15%">Grading System: </td>
	<td width="5%">1.00 </td>
	<td width="10%">(99 - 100%) </td>
	<td width="12%">Excellent </td>
	<td width="5%">2.25</td>
	<td width="10%">(84 - 86%) </td>
	<td width="12%">&nbsp;</td>
	<td width="5%">Inc.</td>
	<td>Incomplete</td>
</tr>
<tr>
  <td>&nbsp;</td>
  <td>1.25</td>
  <td>(96 - 98%) </td>
  <td>&nbsp;</td>
  <td>2.50</td>
  <td>(81 - 83%) </td>
  <td>Superior</td>
  <td>AW</td>
  <td>Authorized Withdrawal </td>
</tr>
<tr>
  <td>&nbsp;</td>
  <td>1.50</td>
  <td>(93 - 95%)</td>
  <td>Very Good </td>
  <td>2.75</td>
  <td>(78 - 80%) </td>
  <td>&nbsp;</td>
  <td>UW</td>
  <td>Unauthorized Withdrawal </td>
</tr>
<tr>
  <td>&nbsp;</td>
  <td>1.75</td>
  <td>(90 - 92%) </td>
  <td>&nbsp;</td>
  <td>3.00 </td>
  <td>(75 - 77%) </td>
  <td>Passed </td>
  <td>DRP</td>
  <td>Dropped</td>
</tr>
<tr>
  <td height="17">&nbsp;</td>
  <td>2.00 </td>
  <td>(87 - 89%) </td>
  <td>Good</td>
  <td>5.00</td>
  <td>(70%)</td>
  <td>Failed</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
</tr>
</table>


<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td colspan="2" height="10">&nbsp;</td>
  </tr>
<% if (iLastPage == 1){ //if last page, i have to show the remark.
	iLastIndex = -1;
	if (WI.fillTextValue("addl_remark").length() > 100){
		iLastIndex = WI.fillTextValue("addl_remark").lastIndexOf(' ',100);
	}

	if (iLastIndex != -1){
%>
  <tr>
    <td width="9%">Remarks: </td>
    <td width="91%" height="18" class="thinborderBOTTOM">&nbsp;
				<%=WI.fillTextValue("addl_remark").substring(0,iLastIndex)%></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td height="18" class="thinborderBOTTOM">&nbsp;<%=WI.fillTextValue("addl_remark").substring(iLastIndex)%></td>
  </tr>


<%
	}else{
%>
  <tr>
    <td width="9%">Remarks: </td>
    <td height="19"class="thinborderBOTTOM">&nbsp;
			<%=WI.fillTextValue("addl_remark")%></td>
  </tr>
  <tr>
    <td align="center">&nbsp;</td>
    <td height="17" align="center" class="thinborderBOTTOM">&nbsp;</td>
  </tr>

<% }// end if line to long
}else{//end of last page.%>
  <tr>
    <td width="9%">Remarks: </td>
    <td height="17"class="thinborderBOTTOM">&nbsp; </td>
  </tr>
  <tr>
    <td align="center">&nbsp;</td>
    <td height="17" align="center" class="thinborderBOTTOM">&nbsp;</td>
  </tr>
<%}%>
  <tr>
    <td height="17" colspan="2" align="center">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td width="35%">Prepared by : <strong><u>&nbsp;&nbsp;<%=WI.fillTextValue("prep_by1")%>&nbsp;&nbsp;</u></strong></td>
    <td width="30%">&nbsp;</td>
    <td width="35%">&nbsp;&nbsp;&nbsp;&nbsp;Verified  by :
			<strong><u>&nbsp;&nbsp;<%=WI.fillTextValue("check_by1")%>&nbsp;&nbsp;</u></strong>	</td>
  </tr>
  
  <tr>
    <td width="35%" height="15">Date Issued : __________________ </td>
    <td width="30%"><div align="center"></div></td>
    <td width="35%">&nbsp;&nbsp;&nbsp;&nbsp;O.R.No. : ____________________</td>
  </tr>
  <tr>
    <td width="35%" height="15">&nbsp;</td>
    <td width="30%" class="thinborderBOTTOM"><div align="center"><strong><%=WI.fillTextValue("registrar_name")%></strong></div></td>
    <td width="35%"><div align="center"></div></td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td><div align="center"> College Registrar</div></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td><div align="center"></div></td>
    <td><div align="center"></div></td>
  </tr>
</table>

<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td width="10%" height="10" valign="top"><font size="1">Note: </font></td>
    <td width="90%" valign="bottom"><font size="1">THIS TRANSCRIPT OF RECORDS IS SUBJECT TO REVOCATION IF THE RECORDS UPON WHICH IT IS BASED<br>
      ARE SUBSEQUENTLY FOUND TO BE FRAUDULENT. ERASURES, CANCELATIONS, OR INSERTIONS WILL <br>
      RENDER THIS RECORD INVALID. </font></td>
  </tr>
  <tr>
    <td height="10" colspan="2" valign="bottom"><font size="1"><strong>NOT VALID WITHOUT SCHOOL SEAL </strong></font></td>
  </tr>
</table>

<%//System.out.println(WI.fillTextValue("print_"));
if(WI.fillTextValue("print_").compareTo("1") == 0){%>
<script language="javascript">
 window.print();
</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
