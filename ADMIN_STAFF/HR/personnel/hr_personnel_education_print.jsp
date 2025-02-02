<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRInfoEducation" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request); 

String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function viewInfo(){
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.page_action.value = "3";
	this.SubmitOnce("staff_profile");	
}
function viewDetail(index){
	var loadPg = "./hr_personnel_educ_detail.jsp?info_index="+index+
	"&my_home="+document.staff_profile.my_home.value+
	"&applicant_=" +document.staff_profile.applicant_.value ;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce("staff_profile");
}

function EditRecord(){

	document.staff_profile.page_action.value="2";
	this.SubmitOnce("staff_profile");
}
function viewEducLevels()
{
	var loadPg = "./hr_educ_levels.jsp";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewSchoolList(){
	var loadPg = "../hr_updateschlist.jsp";
	var win=window.open(loadPg,"newWin",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function DeleteRecord(index){
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
	this.SubmitOnce("staff_profile");
}

function ReloadPage(){
	document.staff_profile.reloadPage.value = "1";
	this.SubmitOnce("staff_profile");
}

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.setEdit.value = "0";
	document.staff_profile.info_index.value = index;
	document.staff_profile.reloadPage.value = "1";
	this.SubmitOnce("staff_profile");
}

function CancelRecord(index){
	location = "./hr_personnel_education.jsp?applicant_="+document.staff_profile.applicant_.value+"&emp_id="+index+
	"&my_home=<%=WI.fillTextValue("my_home")%>";
}
function FocusID() {
<% if (WI.fillTextValue("my_home").compareTo("1") !=0){%>
	document.staff_profile.emp_id.focus();
<%}%>
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	
	//This page is called for applicant as well as for employees, -- do not show search button for applicant.
	boolean bolIsApplicant = false;
	if(WI.fillTextValue("applicant_").compareTo("1") ==0)
		bolIsApplicant = true;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_education.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_education.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		else 
			iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//
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
Vector vRetResult = null;
Vector vEmpRec = null;
Vector vEditResult = null;
String strPrepareToEdit = null;
boolean bNoError = true;
boolean bSetEdit = false;  // to be set when preparetoedit is 1 and okey to edit
String strInfoIndex = WI.fillTextValue("info_index");

strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
String strReloadPage = WI.getStrValue(request.getParameter("reloadpage"),"0");

HRManageList hrList = new HRManageList();
HRInfoEducation hrEduc = new HRInfoEducation();
//HRUpdateTables hrUpdate = new HRUpdateTables();

//hrUpdate.updateEducationTable(dbOP);

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}

if (strTemp.trim().length()> 0){
	
	if(bolIsApplicant){
		hr.HRApplNew hrApplNew = new hr.HRApplNew();
		vEmpRec = hrApplNew.operateOnApplication(dbOP, request,3);//view one
	}else{	
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
		if(vEmpRec == null || vEmpRec.size() ==0)
			strErrMsg = authentication.getErrMsg();
	}
	if (vEmpRec != null && vEmpRec.size() > 0)	{
		bNoError = true;
	}else{		
		bNoError = false;
	}

	if (bNoError) {
		if( iAction == 0 || iAction  == 1 || iAction == 2)
		vRetResult = hrEduc.operateOnEducation(dbOP,request,iAction);


		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null){
					strPrepareToEdit = "";
					if(bolIsApplicant)
						strErrMsg = " Applicant education record removed successfully.";
					else	
						strErrMsg = " Employee education record removed successfully.";
				}
				else
					strErrMsg = hrEduc.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null){
					if(bolIsApplicant)
						strErrMsg = " Applicant education record added successfully.";
					else
						strErrMsg = " Employee education record added successfully.";
				}
				else
					strErrMsg = hrEduc.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					if(bolIsApplicant)
						strErrMsg = " Applicant education record edited successfully.";
					else	
						strErrMsg = " Employee education record edited successfully.";
					strPrepareToEdit = "0";
				}
				else
					strErrMsg = hrEduc.getErrMsg();
				break;
			}
		}
	}
}

if (strPrepareToEdit.compareTo("1") == 0){
	vEditResult = hrEduc.operateOnEducation(dbOP,request,3);

	if (vEditResult != null && vEditResult.size() > 0) 	
		bSetEdit = true;

	if (WI.fillTextValue("setEdit").equals("1"))  
		bSetEdit = false;

}

vRetResult = hrEduc.operateOnEducation(dbOP,request, 4);
if (vRetResult == null) strErrMsg = hrEduc.getErrMsg();

%>
<body onLoad="window.print();">
<% if (strErrMsg != null) {%> 
	<%=WI.getStrValue(strErrMsg)%>
<%} if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td colspan="2"><% if (!WI.fillTextValue("applicant_").equals("1")) {%>
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
              <%=WI.getStrValue(strTemp)%> <br> <br> 
              <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
              <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> 
              <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br>
			<% if (!bolIsApplicant) {%>
			  <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
<% if (!strSchCode.startsWith("AUF")){%> 
             <%="Length of Service : <br>" +   			
				new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%>
<%}%> 
			  </font> 
			 <%}%>
            </td>
          </tr>
        </table>
<%}else{%>
        <table width="400" height="77" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../faculty_img/"+WI.fillTextValue("emp_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%>
              <%=strTemp%><br> <br> <br> <strong><%=WI.formatName((String)vEmpRec.elementAt(1),
			  								(String)vEmpRec.elementAt(2),
						 				    (String)vEmpRec.elementAt(3),4)%></strong><br>
              Position Applying for: <%=WI.getStrValue(vEmpRec.elementAt(11))%><br> 
              <%=WI.getStrValue(vEmpRec.elementAt(5),"<br>","")%> 
              <!-- email -->
              <%=WI.getStrValue(vEmpRec.elementAt(4))%> 
              <!-- contact number. -->
            </td>
          </tr>
        </table>
<%}%></td>
    </tr>
</table>
<%	if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="4" align="center" class="thinborder"><strong><font color="#333333">EDUCATIONAL RECORD(S)</font></strong></td>
    </tr>
    <tr align="center">
      <td width="17%" height="20" class="thinborder"><font size="1"><strong>EDUCATION</strong></font></td>
      <td width="36%" class="thinborder"><font size="1"><strong>SCHOOL</strong></font></td>
      <td width="28%" class="thinborder"><font size="1"><strong>DEGREE</strong></font></td>
      <td width="19%" class="thinborder"><font size="1"><strong>HONORS / AWARDS </strong></font></td>
    </tr>
    <% 	for (int i = 0; i < vRetResult.size(); i +=28) {%>
    <tr>
      <td class="thinborder"><font size="1"><strong><%=(String)vRetResult.elementAt(i+21)%><br>
        </strong> Fr :<%=WI.getStrValue((String)vRetResult.elementAt(i+8),"--") + "/"    + 
	  	 WI.getStrValue((String)vRetResult.elementAt(i+16),"--") + "/" +
		 WI.getStrValue((String)vRetResult.elementAt(i+17),"--")%>	
	  	<br>To : <%=WI.getStrValue((String)vRetResult.elementAt(i+9),"--") + "/" +
	  	 WI.getStrValue((String)vRetResult.elementAt(i+18),"--") + "/" +
		 WI.getStrValue((String)vRetResult.elementAt(i+19),"--")%>	

</font> </td>
      <td class="thinborder"> <font size="1"><strong><%=WI.getStrValue((String)vRetResult.elementAt(i+22),"&nbsp")%><br>
        </strong> <%=WI.getStrValue((String)vRetResult.elementAt(i+23),"&nbsp")%>
		<br>Date Graduated : <%=WI.getStrValue((String)vRetResult.elementAt(i+3),"--") + "/" +
	  	 WI.getStrValue((String)vRetResult.elementAt(i+14),"--") + "/" +
		 WI.getStrValue((String)vRetResult.elementAt(i+15),"--")%>			
		</font></td>
      <td class="thinborder">
	  <% if ( WI.getStrValue((String)vRetResult.elementAt(i+27),"1").equals("1")) {%>
	  	(CAR)
	    <%}%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+25),"(Major in ",")","")%> 
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+26),"(Minor in ",")","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"<br> Units : <strong>","</strong>","")%>	  </td>
<%
	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+24));

	if (strTemp.length() == 0) 
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11),
								"Awards: ","","&nbsp;");
	else
		strTemp += WI.getStrValue((String)vRetResult.elementAt(i+11),
								"<br>Awards: ","","");
%>

      <td class="thinborder"><font size="1">
	  	<%=WI.getStrValue(strTemp,"&nbsp")%>
	  </font></td>
    </tr>
    <% }// end for loop %>
  </table>
<%} // end vRetResult != null
} // end vEmpRec != null
%>

</body>
</html>
<%
dbOP.cleanUP();
%>
